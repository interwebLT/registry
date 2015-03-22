class AddStreetsToContactHistory < ActiveRecord::Migration
  def change
    add_column :contact_history, :street2, :string, limit: 255
    add_column :contact_history, :street3, :string, limit: 255
  end
end
