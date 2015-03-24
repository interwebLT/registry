class AddLocalAddressInfoToContacts < ActiveRecord::Migration
  def change
    add_column :contacts,         :local_name,          :string, limit: 255
    add_column :contacts,         :local_organization,  :string, limit: 255
    add_column :contacts,         :local_street,        :string, limit: 255
    add_column :contacts,         :local_street2,       :string, limit: 255
    add_column :contacts,         :local_street3,       :string, limit: 255
    add_column :contacts,         :local_city,          :string, limit: 255
    add_column :contacts,         :local_state,         :string, limit: 255
    add_column :contacts,         :local_postal_code,   :string, limit: 255
    add_column :contacts,         :local_country_code,  :string, limit: 255

    add_column :contact_history,  :local_name,          :string, limit: 255
    add_column :contact_history,  :local_organization,  :string, limit: 255
    add_column :contact_history,  :local_street,        :string, limit: 255
    add_column :contact_history,  :local_street2,       :string, limit: 255
    add_column :contact_history,  :local_street3,       :string, limit: 255
    add_column :contact_history,  :local_city,          :string, limit: 255
    add_column :contact_history,  :local_state,         :string, limit: 255
    add_column :contact_history,  :local_postal_code,   :string, limit: 255
    add_column :contact_history,  :local_country_code,  :string, limit: 255
  end
end
