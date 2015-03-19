class RegistrantSerializer < ActiveModel::Serializer
  attributes :name, :organization, :street, :city, :state, :postal_code, :country_code, :email, :phone, :fax
end
