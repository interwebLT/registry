class CreateVasOrderDetails < ActiveRecord::Migration
  def change
    create_table :vas_order_details do |t|
      t.integer  :order_id,                                             null: false
      t.integer  :product_id
      t.string   :type,                     limit: 64,                  null: false
      t.integer  :price_cents,                          default: 0,     null: false
      t.string   :price_currency,           limit: 3,   default: "USD", null: false
      t.string   :status,                   limit: 16,                  null: false
      t.string   :domain,                   limit: 255
      t.integer  :period
      t.string   :registrant_handle,        limit: 16
      t.datetime :registered_at
      t.datetime :renewed_at
      t.integer  :credits_cents,                        default: 0
      t.string   :credits_currency,         limit: 3,   default: "USD"
      t.datetime :expires_at
      t.string   :authcode,                 limit: 64
      t.integer  :refunded_order_detail_id
      t.string   :remarks,                              default: ""
      t.timestamps                                                      null: false
    end
  end
end
