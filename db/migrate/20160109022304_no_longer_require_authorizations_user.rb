class NoLongerRequireAuthorizationsUser < ActiveRecord::Migration
  def change
    change_column :authorizations, :user_id, :integer, null: true
  end
end
