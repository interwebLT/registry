class PartnerSerializer < ActiveModel::Serializer
  attributes :id, :name, :organization, :credits, :site, :nature, :representative, :position, :street, :city, :state, :postal_code, :country_code, :phone, :fax, :email, :local, :admin

  def credits
    object.current_balance.to_f
  end

  def site
    object.url
  end

  def phone
    object.voice
  end
end
