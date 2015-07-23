class OrderDetail::TransferDomain < OrderDetail
  def self.build params, partner
    new params.merge(period: 0)
  end

  def self.execute domain:, to:, fee: true
    price = fee ? (to.pricing action: OrderDetail::TransferDomain.new.action, period: 0) : 0.00.money

    o = Order.new partner: to, total_price: price
    od = self.new price: price, domain: domain.full_name
    o.order_details << od
    o.save!

    o.complete!
  end

  def action
    'transfer_domain'
  end

  def complete!
    domain = Domain.named(self.domain)

    if domain.transfer! to: self.order.partner
      self.order.partner.credits.create order: self.order,
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
      object: self.product.as_json
    }
  end
end
