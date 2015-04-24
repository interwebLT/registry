class AddRefundedOrderDetailToOrderDetails < ActiveRecord::Migration
  def change
    change_table :order_details do |t|
      t.references  :refunded_order_detail
    end
  end
end
