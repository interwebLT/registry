class AddClientToApplications < ActiveRecord::Migration
  def change
    add_column :applications, :client, :string, null: false, limit: 16
  end
end
