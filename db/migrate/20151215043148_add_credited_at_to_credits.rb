class AddCreditedAtToCredits < ActiveRecord::Migration
  def change
    add_column :credits, :credited_at, :timestamp
  end
end
