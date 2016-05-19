class Order < ActiveRecord::Base
  belongs_to :partner

  has_many :order_details, dependent: :destroy

  has_one :ledger, dependent: :destroy

  monetize :total_price_cents
  monetize :fee_cents

  validates :order_details, presence: true
  validates :ordered_at, presence: true

  validate :partner_must_exist

  before_create :generate_order_number

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
end
