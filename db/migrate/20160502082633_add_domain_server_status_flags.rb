class AddDomainServerStatusFlags < ActiveRecord::Migration
  def change
    add_column :domains, :server_hold,                :boolean, null: false, default: false
    add_column :domains, :server_delete_prohibited,   :boolean, null: false, default: false
    add_column :domains, :server_renew_prohibited,    :boolean, null: false, default: false
    add_column :domains, :server_transfer_prohibited, :boolean, null: false, default: false
    add_column :domains, :server_update_prohibited,   :boolean, null: false, default: false
  end
end
