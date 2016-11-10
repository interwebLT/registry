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

  if Troy::ExchangeRateTable.table_exists?
    ExchangeRate.all.delete_all

    Troy::ExchangeRateTable.all.each do |troy_rate|
      ExchangeRate.create(
        from_date: troy_rate.fromdate,
        troy_rate: troy_rate.todate,
        usd_rate:  troy_rate.usdrate,
        currency:  troy_rate.currency
      )
    end
  end
end
