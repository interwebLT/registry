class OrderDetail::Refund < OrderDetail
  belongs_to :refunded_order_detail, class_name: OrderDetail

  validates :refunded_order_detail, presence: true

  def self.execute order_id:
    o = Order.find(order_id)
    o.reverse!
  end

  def complete!
    self.refunded_order_detail.reverse!

    self.status = OrderDetail::COMPLETE_ORDER_DETAIL
    self.save!
  end

  def as_json options = nil
    {
      type: 'refund',
      price:  self.price.to_f,
      refunded_order_detail: self.refunded_order_detail.as_json
    }
  end
end
