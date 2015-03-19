class CreditSerializer < ActiveModel::Serializer
  attributes :id, :partner, :order_number, :credits, :credited_at, :created_at, :updated_at

  def partner
    object.partner.name
  end

  def credits
    object.order_details.first.price.to_f
  end

  def credited_at
    object.ordered_at.iso8601
  end
end
