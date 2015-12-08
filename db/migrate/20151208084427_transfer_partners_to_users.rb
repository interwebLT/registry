class TransferPartnersToUsers < ActiveRecord::Migration
  def change
    Partner.all.each do |partner|
      user = User.new
      user.email = partner.email
      user.password = partner.encrypted_password # it's not actually encrypted in partners
      user.username = partner.name

      user.save
    end
  end
end
