class CreateUserDomains < ActiveRecord::Migration
  def change
    create_table :user_domains do |t|
      t.integer :user_id
      t.integer :domain_id

      t.timestamps null: false
    end
  end
end
