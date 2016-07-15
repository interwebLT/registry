class AddEndDateToPowerdnsRecord < ActiveRecord::Migration
  def change
    add_column :powerdns_records, :end_date, :datetime
  end
end
