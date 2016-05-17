class CreateApplications < ActiveRecord::Migration
  def change
    create_table :applications do |t|
      t.references  :partner, null: false
      t.string      :token,   null: false, limit: 32
    end
  end
end
