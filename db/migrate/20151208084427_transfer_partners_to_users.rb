class TransferPartnersToUsers < ActiveRecord::Migration
  def change
    Partner.all.each do |partner|
      user = User.new
      user.email = partner.email
      user.name = partner.name
      user.password = partner.encrypted_password # it's not actually encrypted in partners
      user.username = partner.name
      user.registered_at = partner.created_at
      user.partner = partner

      user.save

      partner.encrypted_password = ''
      partner.save
    end
  end
end
