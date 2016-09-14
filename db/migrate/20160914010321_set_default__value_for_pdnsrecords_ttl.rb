class SetDefaultValueForPdnsrecordsTtl < ActiveRecord::Migration
  def change
    change_column_default :powerdns_records, :ttl, 14400
  end
end
