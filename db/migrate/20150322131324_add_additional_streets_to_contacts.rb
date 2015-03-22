class AddAdditionalStreetsToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :street2, :string, limit: 255
    add_column :contacts, :street3, :string, limit: 255
  end
end
