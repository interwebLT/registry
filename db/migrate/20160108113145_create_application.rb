class CreateApplication < ActiveRecord::Migration
  def change
    create_table :applications do |t|
      t.string  :name,  null: false,  limit: 64
    end
  end
end
