class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string   :email,                null: false, limit: 255
      t.string   :name,                 null: false, limit: 64  
      t.string   :salt,                 null: false, limit: 255 
      t.string   :encrypted_password,   null: false, limit: 255 
      t.string   :username,             null: true,  limit: 255
      t.date     :registered_at,        null: false
      t.references :partner
    end

    add_index :users, :email, :unique => true
  end
end
