class CreateDomainPrivateRegistration < ActiveRecord::Migration
  def change
    create_table :domain_private_registrations do |t|
      t.references         :domain
      t.references         :partner
      t.string             :registrant_handle
      t.boolean            :private, default: false
      t.timestamp          :registered_at
      t.timestamp          :expires_at
      t.timestamps                            null:  false
    end
  end
end
