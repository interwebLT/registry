class CreateDomainSearchLogs < ActiveRecord::Migration
  def change
    create_table :domain_search_logs do |t|
      t.string :name, null: false, limit: 128
      t.timestamps null: false
    end
  end
end
