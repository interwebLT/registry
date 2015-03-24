class RegistrantSerializer < ActiveModel::Serializer
  attributes :name, :organization, :street, :street2, :street3, :city, :state, :postal_code, :country_code, :email, :voice, :fax
end
