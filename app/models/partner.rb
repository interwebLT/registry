require 'bcrypt'

class Partner < ActiveRecord::Base
  TIMEOUT = 15.minutes

  has_many :domains
  has_many :orders
  has_many :partner_configurations
  has_many :partner_pricings
  has_many :credits
  has_many :ledgers
  has_many :hosts
  has_many :authorizations
  has_many :applications
  has_many :contacts
  has_many :object_activities

  validates :name, uniqueness: true

  attr_accessor :token, :client

  store_accessor :preferences

  def self.named partner
    if self.exists? name: partner
      self.find_by name: partner
    else
      self.find partner
    end
  end

  def self.authorize token
    application = Application.find_by token: token

    if application
      Authorization.new partner:  application.partner,
                        token:    application.token,
                        client:   application.client
    else
      conditions = { token: token, last_authorized_at: (Time.current - TIMEOUT)..Time.current }

      Authorization.where(conditions).last
    end
  end

  def password= password
    return if (password.nil? or password.blank?)

    self.salt = BCrypt::Engine.generate_salt
    self.encrypted_password = BCrypt::Engine.hash_secret(password, salt)
  end

  def password_matches password
    encrypted_password == BCrypt::Engine.hash_secret(password, salt)
  end

  def current_balance
    ledgers.map(&:amount).reduce(Money.new(0.00), :+)
  end

  def pricing action:, period:
    partner_pricing = partner_pricings.where(action: action, period: period).first

    partner_pricing ? partner_pricing.price : 0.00.money
  end

  def register_domain domain_name, authcode:, period:, registrant_handle:, registered_at:
    product = Product.create product_type: 'domain'

    domain = Domain.new name: domain_name,
                        partner: self,
                        registered_at: registered_at,
                        expires_at: registered_at + period.to_i.years,
                        authcode: authcode,
                        registrant_handle: registrant_handle,
                        product: product

    domain.save

    domain
  end

  def renew_domain domain_name:, period:
    domain = Domain.named(domain_name)

    raise 'Domain not found' if not domain
    raise 'Domain not owned by partner' if domain.partner != self

    domain.renew period
    domain
  end

  def default_nameservers
    self.partner_configurations.where(config_name: 'nameserver').collect do |configuration|
      configuration.value
    end
  end

  def credit_limit
    credit_limit = self.partner_configurations.where(config_name:"credit_limit").first

    if credit_limit
      credit_limit.value
    else
      Rails.configuration.default_credit_limit.to_s
    end
  end

  def credit_history
    self.credits.where(status: Credit::COMPLETE_CREDIT).order(:created_at)

#    quick_orders.select do |order|
#      order.order_details.first.is_a? OrderDetail::ReplenishCredits
#    end
  end

  def order_history
    quick_orders.reject do |order|
      order.order_details.first.is_a? OrderDetail::ReplenishCredits
    end
  end

  def clear_data
    orders.destroy_all
    credits.destroy_all
    domains.destroy_all
    hosts.destroy_all
    contacts.destroy_all
    object_activities.destroy_all
  end

  def migrate_credits
    sinag_partners = SinagPartner.all.pluck(:name)

    unless sinag_partners.include?(self.name)
      troy_user = Troy::User.find_by_userid(self.name)
      unless troy_user.nil?
        partner_credit_available = 0
        partner_credit_used      = 0
        unless Troy::CreditAvailable.where("userrefkey=?", troy_user.userrefkey).first.nil?
          partner_credit_available = Troy::CreditAvailable.where("userrefkey=?", troy_user.userrefkey).pluck(:numcredits).sum.to_f
        end
        unless Troy::Creditused.where("userrefkey=?", troy_user.userrefkey).first.nil?
          partner_credit_used      = Troy::Creditused.where("userrefkey=?", troy_user.userrefkey).pluck(:numcredits).sum.to_f
        end

        credit_for_top_up = partner_credit_available - partner_credit_used

        if credit_for_top_up > 0
          Credit::BankReplenish.execute partner: partner.name,
                                        credit: credit_for_top_up,
                                        remarks: 'Top up from credit migration',
                                        at: Date.today.in_time_zone
          puts "Credit migration for #{partner.name} successfully done."
        end
      end
    end
  end

  private

  def quick_orders
    self.orders.where(status: [Order::COMPLETE_ORDER, Order::REVERSED_ORDER])
      .includes(partner: :credits, order_details: [product: [:domain]]).order(:ordered_at)
  end
end
