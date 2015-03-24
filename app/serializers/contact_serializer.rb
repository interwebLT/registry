class ContactSerializer < ActiveModel::Serializer
  attributes :handle, :name, :email, :organization, :voice, :fax, :street, :street2, :street3, :city, :state, :country_code, :postal_code
end
