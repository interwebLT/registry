class CreditSerializer < ActiveModel::Serializer
  attributes :id, :partner_id, :partner, :credit_number, :amount, :fee, :credited_at, :created_at, :updated_at, :verification_code

  def partner_id
    object.partner.id
  end
  
  def partner
    object.partner.name
  end

  def amount
    object.amount.to_f
  end
  
  def fee
    object.fee.to_f
  end

  def credited_at
    object.credited_at.iso8601
  end
end
