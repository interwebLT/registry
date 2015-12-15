class AddAmountToLedger < ActiveRecord::Migration
  def change
    add_monetize :ledger, :amount

    Ledger.all.each do |entry|
      entry.amount = (entry.credits).money
      entry.save!
    end

    change_column :ledger, :credits, :numeric, null: true
  end
end
