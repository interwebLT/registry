class CreatePowerdnsDomains < ActiveRecord::Migration
  def change
    create_table :powerdns_domains do |t|
      t.references  :domain,            null: false
      t.integer     :notified_serial,   null: false, default: 1
      t.string		:name,				null: false
      t.timestamps                      null: false
    end
  end
end
