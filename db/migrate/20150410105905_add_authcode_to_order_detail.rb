class AddAuthcodeToOrderDetail < ActiveRecord::Migration
  def change
    add_column :order_details, :authcode, :string, limit: 64
  end
end
