class CreateCredits < ActiveRecord::Migration
  def change
    create_table :credits do |t|
      t.integer :partner_id
      t.string :type
      t.string :status
      t.integer :amount_cents
      t.string :amount_currency
      t.string :verification_code
      t.string :remarks
      t.string :credit_number

      t.timestamps null: false
    end
  end
end
