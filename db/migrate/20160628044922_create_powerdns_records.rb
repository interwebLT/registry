class CreatePowerdnsRecords < ActiveRecord::Migration
  def change
    create_table :powerdns_records do |t|
      t.references :powerdns_domain,        null: false
      t.string  :name,       limit: 255,    null: false, index: true
      t.string  :type,       limit: 10,     null: false
      t.text    :content,    limit: 65535
      t.integer :ttl
      t.integer :prio
      t.integer :change_date
      t.timestamps                          null: false
    end
  end
end
