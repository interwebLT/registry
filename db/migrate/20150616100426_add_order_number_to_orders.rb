class AddOrderNumberToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :order_number, :string

    add_index :orders, :order_number, :unique => true

    Order.find_each do |order|
      num = SecureRandom.hex[0...10].upcase
      while Order.exists? order_number: num
        num = SecureRandom.hex[0...10].upcase
      end

      order.order_number = num
      order.save!
    end
  end
end
