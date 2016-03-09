class OrderDetail::RegisterDomain < OrderDetail
  validates :domain,            presence: true
  validates :authcode,          presence: true
  validates :period,            presence: true
  validates :registrant_handle, presence: true

  def self.build params, partner
    new params
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

  def sync!
    SyncOrderJob.perform_later self.order.partner, self.as_json_request
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
