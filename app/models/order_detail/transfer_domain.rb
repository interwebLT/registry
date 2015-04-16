class OrderDetail::TransferDomain < OrderDetail
  def self.build params, partner
    new params
  end

  def action
    'transfer_domain'
  end

  def complete!
    domain = Domain.named(self.domain)

    old_partner = domain.partner

    domain.partner = self.order.partner

    if domain.save
      ObjectActivity::Transfer.create activity_at: Time.now,
                                      partner: domain.partner,
                                      product: domain.product,
                                      losing_partner: old_partner

      self.order.partner.credits.create order: self.order,
                                        credits: self.price * -1,
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
      type: 'domain_transfer',
      price: self.price.to_f,
      domain: self.domain
    }
  end
end
