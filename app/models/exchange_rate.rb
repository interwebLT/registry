class ExchangeRate < ActiveRecord::Base
  def self.current_rate params
    current_rate = ExchangeRate.where("? > from_date and ? < to_date", params, params)
    current_rate
  end
end
