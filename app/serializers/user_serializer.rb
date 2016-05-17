class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :token, :partner_id, :partner_name, :credits, :transactions_allowed, :admin, :staff, :email

  def username
    object.name
  end

  def partner_id
    object.id
  end

  def partner_name
    object.name
  end

  def credits
    object.current_balance.to_f
  end

  def transactions_allowed
    true
  end

  def admin
    object.admin
  end

  def staff
    object.staff
  end
end
