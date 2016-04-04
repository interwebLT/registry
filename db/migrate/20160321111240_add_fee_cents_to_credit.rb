class AddFeeCentsToCredit < ActiveRecord::Migration
  def change
    add_column :credits, :fee_cents, :integer
  end
end
