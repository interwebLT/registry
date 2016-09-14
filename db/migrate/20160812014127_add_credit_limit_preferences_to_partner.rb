class AddCreditLimitPreferencesToPartner < ActiveRecord::Migration
  def change
    enable_extension "hstore"
    add_column :partners, :preferences, :hstore
    add_index :partners, :preferences, using: :gist
  end
end
