class CreateMigratedDomains < ActiveRecord::Migration
  def change
    create_table :migrated_domains do |t|
      t.references  :partner,                       null: false
      t.string      :name,              limit: 128, null: false
      t.string      :registrant_handle, limit: 16,  null: false
      t.timestamp   :registered_at,                 null: false
      t.timestamp   :expires_at,                    null: false
      t.string      :authcode,                      null: false

      t.timestamps null: false
    end
  end
end
