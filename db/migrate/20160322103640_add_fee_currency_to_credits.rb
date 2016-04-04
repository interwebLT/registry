class AddFeeCurrencyToCredits < ActiveRecord::Migration
  def change
    add_column :credits, :fee_currency, :string, limit: 3, default: "USD"
  end
end
