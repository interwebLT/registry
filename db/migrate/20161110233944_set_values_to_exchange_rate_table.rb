class SetValuesToExchangeRateTable < ActiveRecord::Migration
  def change
    if Troy::ExchangeRateTable.table_exists?
      if ExchangeRate.table_exists?
        ExchangeRate.all.delete_all
      end

      Troy::ExchangeRateTable.all.each do |troy_rate|
        ExchangeRate.create(
          from_date: troy_rate.fromdate,
          to_date:   troy_rate.todate,
          usd_rate:  troy_rate.usdrate,
          currency:  troy_rate.currency
        )
      end
    end
  end
end
