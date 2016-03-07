class OrderDetail::RegisterDomain < OrderDetail
  validates :domain,            presence: true
  validates :authcode,          presence: true
  validates :period,            presence: true
  validates :registrant_handle, presence: true

  def self.build params, partner
    new params
  end

  def self.execute partner:, domain:, authcode:, period:, registrant_handle:, at: Time.current, skip_create: false
    owning_partner = Partner.find_by! name: partner

    price = owning_partner.pricing action: self.new.action, period: period

    order = Order.new partner: owning_partner,
                      total_price:  price,
                      ordered_at: at

    order_detail = self.new price: price,
                            domain: domain,
                            authcode: authcode,
                            period: period,
                            registrant_handle:  registrant_handle

    order.order_details << order_detail
    order.save!

    unless skip_create
      order.complete!

      Domain.named(domain).domain_activities.last.update! activity_at: at
    else
      order.update! status: Order::COMPLETE_ORDER, completed_at: Time.current
      order_detail.update! status: OrderDetail::COMPLETE_ORDER_DETAIL
    end
  end

  def action
    'domain_create'
  end

  def complete!
    new_domain = self.order.partner.register_domain self.domain,
                                                    authcode: self.authcode,
                                                    period: self.period,
                                                    registrant_handle: self.registrant_handle,
                                                    registered_at: self.order.ordered_at

    if new_domain.errors.empty?
      self.product = new_domain.product
      self.status = COMPLETE_ORDER_DETAIL

      self.order.partner.ledgers.create  order: self.order,
                                        amount: self.price * -1,
                                        activity_type: 'use'
    else
      self.status = ERROR_ORDER_DETAIL
    end

    self.save

    new_domain.errors.each do |field, code|
      errors.add(field, code)
    end

    self.complete?
  end

  def as_json options = nil
    {
      type:               'domain_create',
      price:              self.price.to_f,
      domain:             self.domain,
      object:             self.product.as_json,
      authcode:           self.authcode,
      period:             self.period,
      registrant_handle:  self.registrant_handle
    }
  end

  def as_json_request
    {
      currency_code:  'USD',
      ordered_at: self.order.ordered_at.iso8601,
      order_details: [
        {
          type: self.action,
          domain: self.domain,
          authcode: self.authcode,
          period: self.period,
          registrant_handle:  self.registrant_handle
        }
      ]
    }
  end
end
