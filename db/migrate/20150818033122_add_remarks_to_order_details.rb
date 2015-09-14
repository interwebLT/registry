class AddRemarksToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :remarks, :string, default: ''
  end
end
