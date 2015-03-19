class ContactSerializer < ActiveModel::Serializer
  attributes :handle, :name, :email, :organization, :phone, :fax, :street, :city, :state, :country_code, :postal_code
end
