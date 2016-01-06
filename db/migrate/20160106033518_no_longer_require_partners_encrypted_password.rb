class NoLongerRequirePartnersEncryptedPassword < ActiveRecord::Migration
  def change
    change_table :partners do |t|
      t.change :encrypted_password, :string,  limit: 255, null: true
    end

    Partner.all.each do |partner|
      partner.update! encrypted_password: nil
    end
  end
end
