class CreateExcludedPartners < ActiveRecord::Migration
  def change
    create_table :excluded_partners do |t|
      t.string  :name,  limit: 16,  null: false

      t.timestamps null: false
    end
  end
end
