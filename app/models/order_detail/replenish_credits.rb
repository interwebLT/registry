class OrderDetail::ReplenishCredits < OrderDetail
  def self.build params, partner
    order_detail = self.new
    order_detail.price = params[:credits].money
    order_detail.credits = params[:credits].money

    order_detail
  end

  def self.execute partner:, credits:
    price = credits.money

    o = Order.new partner: partner, total_price: price
    od = self.new price: price, credits: price
    o.order_details << od
    o.save!

    o.complete!
  end

  def action
    'credits'
  end

  def complete!
    self.status = COMPLETE_ORDER_DETAIL

    self.order.partner.credits.create order: self.order,
                                      amount: self.price,
                                      activity_type: 'topup'

    self.save
  end

  def as_json options = nil
    {
      type: 'credits',
      object: self.product.as_json,
      price: price.to_f,
    }
  end
end
