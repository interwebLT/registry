class OrderDetail::Refund < OrderDetail
  belongs_to :refunded_order_detail, class_name: OrderDetail

  validates :refunded_order_detail, presence: true
end
