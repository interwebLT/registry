class AddPartnerReferenceToAuthorizations < ActiveRecord::Migration
  def change
    change_column :authorizations, :user_id, :integer, null: true

    add_column :authorizations, :partner_id, :integer

    Authorization.all.each do |authorization|
      authorization.update! partner: authorization.user.partner
    end

    change_column :authorizations, :partner_id, :integer, null: false
  end
end
