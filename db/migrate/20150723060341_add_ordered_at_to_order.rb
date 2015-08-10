class AddOrderedAtToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :ordered_at, :timestamp, null: true

    Order.all.each do |order|
      od = order.order_details.first

      order.ordered_at = (od.registered_at || od.renewed_at || order.created_at)
      order.save!
    end

    change_column :orders, :ordered_at, :timestamp, null: false
  end
end
