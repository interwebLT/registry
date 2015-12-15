class AddCreditIdToLedger < ActiveRecord::Migration
  def change
    add_column :ledger, :credit_id, :integer
  end
end
