class ContactSerializer < ActiveModel::Serializer
  attributes  :handle,
              :name, :organization, :street, :street2, :street3,
              :city, :state, :postal_code, :country_code,
              :local_name, :local_organization, :local_street, :local_street2, :local_street3,
              :local_city, :local_state, :local_postal_code, :local_country_code,
              :voice, :voice_ext, :fax, :fax_ext, :email
end
