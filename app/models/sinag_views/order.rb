class SinagViews::Order < ActiveRecord::Base
  self.table_name = "sinag_order_and_order_details"

  def ordered_at
    self[:ordered_at].to_date
  end
end