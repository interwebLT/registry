class OrderSerializer < ActiveModel::Serializer
  attributes :id, :partner, :order_number, :total_price, :fee, :ordered_at, :status, :currency_code, :order_details

  def partner
    object.partner.name if object.partner
  end

  def total_price
    object.total_price.to_f
  end

  def fee
    object.fee.to_f
  end

  def ordered_at
    object.ordered_at.iso8601
  end

  def currency_code
    'USD'
  end

  def order_details
    object.order_details.collect do |order_detail|
      order_detail.as_json
    end
  end
end
