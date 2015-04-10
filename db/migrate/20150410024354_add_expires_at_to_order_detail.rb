class AddExpiresAtToOrderDetail < ActiveRecord::Migration
  def change
    add_column :order_details, :expires_at, :timestamp
  end
end
