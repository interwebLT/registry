class CreditSerializer < ActiveModel::Serializer
  attributes :id, :partner, :credit_number, :amount, :credited_at, :created_at, :updated_at

  def partner
    object.partner.name
  end

  def amount
    object.amount.to_f
  end

  def credited_at
    object.credited_at.iso8601
  end
end
