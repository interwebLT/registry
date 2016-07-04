class CreateNameservers < ActiveRecord::Migration
  def change
    create_table :nameservers do |t|
      t.string :name,  	null: false
      t.timestamps 		null: false
    end
  end
end
