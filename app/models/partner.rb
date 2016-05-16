class Partner < ActiveRecord::Base
  has_many :domains
  has_many :orders
  has_many :partner_configurations
  has_many :partner_pricings
  has_many :credits
  has_many :ledgers
  has_many :hosts
  has_many :authorizations

  validates :name, uniqueness: true

  def self.build params
    name      = params[:name]
    password  = params.delete(:epp_password)

    self.create! params

    SyncCreatePartnerJob.perform_later name, password
  end

  def self.named partner
    if self.exists? name: partner
      self.find_by name: partner
    else
      self.find partner
    end
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

  private

  def quick_orders
    self.orders.where(status: [Order::COMPLETE_ORDER, Order::REVERSED_ORDER])
      .includes(partner: :credits, order_details: [product: [:domain]]).order(:ordered_at)
  end
end
