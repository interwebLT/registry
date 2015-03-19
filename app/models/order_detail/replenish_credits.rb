class OrderDetail::ReplenishCredits < OrderDetail
  def self.build params, partner
    order_detail = self.new
    order_detail.price = params[:credits].money
    order_detail.credits = params[:credits].money

    order_detail
  end

  def action
    'credits'
  end

  def complete!
    self.status = COMPLETE_ORDER_DETAIL

    self.order.partner.credits.create order: self.order,
                                      credits: self.price,
                                      activity_type: 'topup'

    self.save
  end

  def as_json options = nil
    {
      type: 'credits',
      price: price.to_f,
    }
  end
end
