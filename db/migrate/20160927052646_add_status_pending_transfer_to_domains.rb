class AddStatusPendingTransferToDomains < ActiveRecord::Migration
  def change
    add_column :domains, :status_pending_transfer, :string
  end
end
