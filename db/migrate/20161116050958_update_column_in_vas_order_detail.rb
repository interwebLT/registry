class UpdateColumnInVasOrderDetail < ActiveRecord::Migration
  def change
    remove_column :vas_order_details, :order_id
    add_column    :vas_order_details, :vas_order_id, :integer
  end
end