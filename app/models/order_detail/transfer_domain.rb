class OrderDetail::TransferDomain < OrderDetail
  def self.build params, partner
    new params
  end

  def self.execute domain:, to:
    price = to.pricing action: OrderDetail::TransferDomain.new.action, period: 0

    o = Order.new partner: to, status: Order::PENDING_ORDER, total_price: price
    od = self.new status: OrderDetail::PENDING_ORDER_DETAIL, price: price, domain: domain.full_name
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
      type: self.action,
      price: self.price.to_f,
      domain: self.domain
    }
  end
end
