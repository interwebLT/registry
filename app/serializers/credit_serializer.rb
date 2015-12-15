class CreditSerializer < ActiveModel::Serializer
  attributes :id, :partner, :credit_number, :credits, :credited_at, :created_at, :updated_at

  def partner
    object.partner.name
  end

  def credits
    object.amount.to_f
  end

  def credited_at
    object.credited_at.iso8601
  end
end
