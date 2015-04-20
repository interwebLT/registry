class CreateDeletedDomains < ActiveRecord::Migration
  def change
    create_table :deleted_domains do |t|
      t.references  :product,           null: false
      t.references  :partner,           null: false
      t.string      :name,              null: false,  limit: 128
      t.string      :authcode,          null: false,  limit: 64
      t.string      :registrant_handle, null: false,  limit: 16
      t.string      :admin_handle,                    limit: 16
      t.string      :billing_handle,                  limit: 16
      t.string      :tech_handle,                     limit: 16
      t.timestamp   :registered_at,     null: false
      t.timestamp   :expires_at,        null: false
      t.timestamp   :deleted_at,        null: false

      t.timestamps  null: false
    end
  end
end
