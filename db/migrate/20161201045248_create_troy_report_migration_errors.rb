class CreateTroyReportMigrationErrors < ActiveRecord::Migration
  def change
    create_table :troy_report_migration_errors do |t|
      t.string      :troy_order_number
      t.string      :affecting_order_number
      t.text        :log_description
      t.text        :domain
      t.string      :source
      t.timestamps  null: false
    end
  end
end
