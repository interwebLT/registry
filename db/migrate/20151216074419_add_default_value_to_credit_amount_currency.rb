class AddDefaultValueToCreditAmountCurrency < ActiveRecord::Migration
  def change
    change_column :credits, :amount_currency, :string, :limit => 3, :default => 'USD'
  end
end
