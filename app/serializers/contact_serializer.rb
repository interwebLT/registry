class ContactSerializer < ActiveModel::Serializer
  attributes  :handle, :name, :email, :organization,
              :voice, :voice_ext, :fax, :fax_ext,
              :street, :street2, :street3, :city, :state, :country_code, :postal_code
end
