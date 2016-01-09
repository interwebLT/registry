class AddTypeToAuthorization < ActiveRecord::Migration
  def change
    add_column :authorizations, :type, :string, limit: 64

    Authorization.all.each do |authorization|
      authorization.update! authorization: UserAuthorization.to_s
    end

    change_column :authorizations, :type, :string, null: false, limit: 64
  end
end
