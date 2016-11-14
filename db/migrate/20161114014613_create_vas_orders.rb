class CreateVasOrders < ActiveRecord::Migration
  def change
    create_table :vas_orders do |t|
      t.integer  :partner_id,                                      null: false
      t.string   :status,               limit: 16,                 null: false
      t.integer  :total_price_cents,               default: 0,     null: false
      t.string   :total_price_currency, limit: 3,  default: "USD", null: false
      t.integer  :fee_cents,                       default: 0,     null: false
      t.string   :fee_currency,         limit: 3,  default: "USD", null: false
      t.datetime :completed_at
      t.string   :order_number
      t.datetime :ordered_at,                                      null: false
      t.timestamps                                                 null: false
    end
  end
end
