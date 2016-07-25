class AddColumnsToPdnsRecord < ActiveRecord::Migration
  def change
    add_column :powerdns_records, :active, :boolean
    add_column :powerdns_records, :start_date, :datetime
  end
end
