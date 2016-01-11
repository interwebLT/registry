class AddLastAuthorizedAtToAuthorization < ActiveRecord::Migration
  def change
    add_column :authorizations, :last_authorized_at, :timestamp

    Authorization.all.each do |authorization|
      authorization.update! last_authorized_at: authorization.updated_at
    end

    change_column :authorizations, :last_authorized_at, :timestamp, null: false
  end
end
