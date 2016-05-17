class CreateExternalRegistries < ActiveRecord::Migration
  def change
    create_table :external_registries do |t|
      t.string  :name,  null: false,  limit: 16
      t.string  :url,   null: false,  limit: 255
    end
  end
end
