class AddStatusFieldsToDeletedDomains < ActiveRecord::Migration
  def change
    add_column :deleted_domains, :ok,                         :boolean, null: false, default: false
    add_column :deleted_domains, :inactive,                   :boolean, null: false, default: true
    add_column :deleted_domains, :client_hold,                :boolean, null: false, default: false
    add_column :deleted_domains, :client_delete_prohibited,   :boolean, null: false, default: false
    add_column :deleted_domains, :client_renew_prohibited,    :boolean, null: false, default: false
    add_column :deleted_domains, :client_transfer_prohibited, :boolean, null: false, default: false
    add_column :deleted_domains, :client_update_prohibited,   :boolean, null: false, default: false

    DeletedDomain.all.each do |dom|
      statuses = [:ok, :inactive, :client_hold, :client_delete_prohibited, 
        :client_renew_prohibited, :client_transfer_prohibited, 
        :client_update_prohibited]
      statuses.each do |status|
        dom.send("#{status}=", dom.product.object_status.send(status))
      end

      dom.save
    end
  end
end
