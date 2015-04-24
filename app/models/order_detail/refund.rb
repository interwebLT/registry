class OrderDetail::Refund < OrderDetail
  belongs_to :refunded_order_detail, class_name: OrderDetail

  validates :refunded_order_detail, presence: true

  def complete!
    self.refunded_order_detail.reverse!

    self.status = OrderDetail::COMPLETE_ORDER_DETAIL
    self.save!
  end
end
