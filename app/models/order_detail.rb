class OrderDetail < ActiveRecord::Base
  belongs_to :order
  belongs_to :product

  monetize :price_cents, allow_nil: true
  monetize :credits_cents

  validates :type,  presence: true
  validates :price, presence: true
#  validates :price, numericality: { greater_than: 0.00 }

  after_initialize do
    self.status ||= PENDING_ORDER_DETAIL
  end

  PENDING_ORDER_DETAIL  = 'pending'
  COMPLETE_ORDER_DETAIL = 'complete'
  ERROR_ORDER_DETAIL    = 'error'
  REVERSED_ORDER_DETAIL = 'reversed'

  ORDER_DETAIL_TYPES = {
    domain_create: OrderDetail::RegisterDomain,
    domain_renew: OrderDetail::RenewDomain,
    credits: OrderDetail::ReplenishCredits,
    migrate_domain: OrderDetail::MigrateDomain,
    transfer_domain:  OrderDetail::TransferDomain
  }

  def self.build params, partner
    type_action = params.delete(:type)
    type = ORDER_DETAIL_TYPES[type_action.to_sym]

    order_detail = (type ? type.build(params, partner) : new(params))
    order_detail.status = 'pending'

    order_detail.price = (partner ? partner.pricing(action: type_action, period: order_detail.period) : 0.00.money) if order_detail.price == 0.00.money

    order_detail
  end

  def pending?
    self.status == PENDING_ORDER_DETAIL
  end

  def complete?
    status == COMPLETE_ORDER_DETAIL
  end

  def error?
    status == ERROR_ORDER_DETAIL
  end

  def reversed?
    status == REVERSED_ORDER_DETAIL
  end

  def complete!
    self.status = COMPLETE_ORDER_DETAIL

    self.save
  end

  def action
    ''
  end
end
