class RemoveNotNullConstraintOnOrderIdInLedger < ActiveRecord::Migration
  def change
    change_column :ledger, :order_id, :integer, :null => true
  end
end
