class AddDomainIdToDeletedDomain < ActiveRecord::Migration
  def change
    add_column :deleted_domains, :domain_id, :integer, null: false
  end
end
