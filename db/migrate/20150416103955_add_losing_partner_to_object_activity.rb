class AddLosingPartnerToObjectActivity < ActiveRecord::Migration
  def change
    change_table :object_activities do |t|
      t.references :losing_partner
    end
  end
end
