class CreateExchangeRateTable < ActiveRecord::Migration
  def change
    create_table :exchange_rates do |t|
      t.date     :from_date
      t.date     :to_date
      t.decimal  :usd_rate
      t.string   :currency
      t.timestamps
    end
  end
end
