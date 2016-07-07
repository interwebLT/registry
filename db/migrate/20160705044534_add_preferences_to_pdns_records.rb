class AddPreferencesToPdnsRecords < ActiveRecord::Migration
  def change
    enable_extension "hstore"
    add_column :powerdns_records, :preferences, :hstore
    add_index :powerdns_records, :preferences, using: :gist
  end
end
