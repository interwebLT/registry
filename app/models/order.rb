class Order < ActiveRecord::Base
  belongs_to :partner

  has_many :order_details, dependent: :destroy

  has_one :ledger, dependent: :destroy

  monetize :total_price_cents
  monetize :fee_cents

  validates :order_details, presence: true
  validates :ordered_at, presence: true

  validate :partner_must_exist
  validate :validate_credit_sufficiency, on: :create

  before_create :generate_order_number
  before_create :get_credit_before_create

  after_save :check_credit_balance
  after_save :check_credit_limit_percentage

  skip_callback :create, :before, :generate_order_number,         if: :troy_migration
  skip_callback :create, :before, :get_credit_before_create,      if: :troy_migration
  skip_callback :save,   :after,  :check_credit_balance,          if: :troy_migration
  skip_callback :save,   :after,  :check_credit_limit_percentage, if: :troy_migration

  attr_accessor :troy_migration


  COMPLETE_ORDER  = 'complete'
  PENDING_ORDER   = 'pending'
  ERROR_ORDER     = 'error why'
  REVERSED_ORDER  = 'reversed'

  after_initialize do
    self.status ||= PENDING_ORDER
  end

  def self.build params, partner
    params[:order_details] ||= []

    order = Order.new
    order.partner = partner
    order.fee = Money.new(params[:fee])
    order.status = 'pending'
    order.ordered_at = params[:ordered_at] || Time.current
    order.order_details << params[:order_details].collect { |o| OrderDetail.build(o, partner) }
    order.total_price = order.order_details.map(&:price).reduce(Money::ZERO, :+)

    order
  end

  def self.latest
    all.includes(:order_details, partner: :credits).order(ordered_at: :desc).limit(500)
  end

  def complete?
    status == COMPLETE_ORDER
  end

  def pending?
    status == PENDING_ORDER
  end

  def error?
    status == ERROR_ORDER
  end

  def reversed?
    status == REVERSED_ORDER
  end

  def complete!
    self.status = COMPLETE_ORDER
    self.completed_at = Time.current

    saved_errors = {}

    self.order_details.each do |order_detail|
      unless order_detail.complete!
        order_detail.errors.each do |field, code|
          saved_errors[field] = code
        end

        self.status = ERROR_ORDER
      end
    end

    self.save

    saved_errors.each do |field, code|
      errors.add(field, code)
    end

    complete?
  end

  def reverse!
    reversed_order = Order.new  partner:  self.partner,
                                total_price:  self.total_price * -1,
                                ordered_at: Time.current

    self.order_details.each do |order_detail|
      refund = OrderDetail::Refund.new  product:  order_detail.product,
                                        price:  order_detail.price * -1,
                                        refunded_order_detail: order_detail

      reversed_order.order_details << refund
    end

    reversed_order.save!

    self.status = REVERSED_ORDER
    self.save!

    reversed_order.complete!
  end

  def contains_checkout_credits?
    self.order_details.where(type: OrderDetail::CheckoutReplenishCredits).count > 0
  end

  private

  def generate_order_number
    self.order_number = loop do
      order_number = SecureRandom.hex(5).upcase
      break order_number unless self.class.exists? order_number: order_number
    end
  end

  def partner_must_exist
    errors.add :partner, I18n.t('errors.messages.invalid') if partner.nil?
  end

  def check_credit_balance
    if Rails.configuration.activate_credit_validation
      if self.status == COMPLETE_ORDER
        balance_before_transaction = @current_balance
        current_balance   = ActionController::Base.helpers.humanized_money(self.partner.current_balance).gsub(',','').to_i
        if balance_before_transaction > Rails.configuration.cl_notice_threshold.to_i
          if current_balance < Rails.configuration.cl_notice_threshold.to_i
            PartnerCreditMailer.delay_for(5.minute, queue: "registry_mailer").credit_balance_below_threshold(self)
          end
        end
        if balance_before_transaction > 0
          if current_balance < 0
            PartnerCreditMailer.delay_for(5.minute, queue: "registry_mailer").credit_balance_notification(self)
          end
        end
      end
    end
  end

  def check_credit_limit_percentage
    if Rails.configuration.activate_credit_validation
      if self.status == COMPLETE_ORDER && Rails.configuration.cl_notice_active
        current_balance   = ActionController::Base.helpers.humanized_money(self.partner.current_balance).gsub(',','').to_i
        if current_balance < 0
          current_credit_limit = current_balance + @credit_limit

          credit_limit_first_boundary  = @credit_limit * Rails.configuration.first_notice.to_f
          credit_limit_second_boundary = @credit_limit * Rails.configuration.second_notice.to_f
          credit_limit_third_boundary  = @credit_limit * Rails.configuration.third_notice.to_f

          if credit_limit_first_boundary > current_credit_limit
            if self.partner.preferences.nil?
              self.partner.preferences = {cl_first_notice: "true" }
              self.partner.save!
              PartnerCreditMailer.delay_for(5.minute, queue: "registry_mailer").credit_limit_notice(self, "first")
            end
          end

          if credit_limit_second_boundary > current_credit_limit
            unless self.partner.preferences.nil?
              if self.partner.preferences["cl_second_notice"].nil?
                self.partner.preferences["cl_second_notice"] = true
                self.partner.save!
                PartnerCreditMailer.delay_for(5.minute, queue: "registry_mailer").credit_limit_notice(self, "second")
              end
            end
          end

          if credit_limit_third_boundary > current_credit_limit
            unless self.partner.preferences.nil?
              if self.partner.preferences["cl_third_notice"].nil?
                self.partner.preferences["cl_third_notice"] = true
                self.partner.save!
                PartnerCreditMailer.delay_for(5.minute, queue: "registry_mailer").credit_limit_notice(self, "third")
              end
            end
          end
        end
      end
    end
  end

  def get_credit_before_create
    if Rails.configuration.activate_credit_validation
      unless partner.nil?
        @current_balance = ActionController::Base.helpers.humanized_money(self.partner.current_balance).gsub(/,/,'').to_i
        @credit_limit    = self.partner.credit_limit.to_i
      end
    end
  end

  def validate_credit_sufficiency
    if Rails.configuration.activate_credit_validation
      unless partner.nil?
        sufficient_credit = true
        @credit_limit      = self.partner.credit_limit.to_i
        current_balance   = ActionController::Base.helpers.humanized_money(self.partner.current_balance).gsub(/,/,'').to_i
        total_credit      = @credit_limit + current_balance
        order_price       = self.total_price_cents / 100
        sufficient_credit = total_credit >= order_price

        unless sufficient_credit
          if !self.troy_migration
            errors.add(:total_price_cents, "You don't have enough credit balance to complete this order.")
          end
        end
      end
    end
  end
end