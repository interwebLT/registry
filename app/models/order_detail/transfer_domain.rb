class OrderDetail::TransferDomain < OrderDetail
  validates :registrant_handle, presence: true

  def self.build params, partner
    new params.merge(period: 0)
  end

  def action
    'transfer_domain'
  end

  def complete!
    domain = Domain.named(self.domain)

    if domain.transfer! to: self.order.partner, handle: self.registrant_handle
      self.order.partner.ledgers.create order: self.order,
                                        amount: self.price * -1,
                                        activity_type: 'use'

      self.product = domain.product
      self.status = COMPLETE_ORDER_DETAIL
    else
      self.status = ERROR_ORDER_DETAIL
    end

    self.save

    complete?
  end

  def as_json options = nil
    {
      type: self.action,
      price: self.price.to_f,
      domain: self.domain,
      registrant_handle: self.registrant_handle,
      object: self.product.as_json
    }
  end
end
