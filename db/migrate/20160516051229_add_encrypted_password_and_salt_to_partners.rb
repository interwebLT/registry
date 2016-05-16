class AddEncryptedPasswordAndSaltToPartners < ActiveRecord::Migration
  def change
    add_column :partners, :salt, :string, limit: 255

    User.all.each do |user|
      next if user.username.blank?

      user.partner.update salt: user.salt,
                          encrypted_password: user.encrypted_password
    end

    change_column :partners, :salt,               :string, limit: 255, null: false
    change_column :partners, :encrypted_password, :string, limit: 255, null: false
  end
end
