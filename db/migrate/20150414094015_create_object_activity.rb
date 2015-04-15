class CreateObjectActivity < ActiveRecord::Migration
  def change
    create_table :object_activities do |t|
      t.string      :type,              null: false,  limit: 64

      t.references  :partner,           null: false
      t.references  :product,           null: false
      t.timestamp   :activity_at,       null: false

      t.string      :registrant_handle,               limit: 16
      t.string      :authcode,                        limit: 64
      t.timestamp   :expires_at

      t.string      :property_changed,                limit: 64
      t.string      :old_value,                       limit: 255
      t.string      :value,                           limit: 255

      t.timestamps null: false
    end
  end
end
