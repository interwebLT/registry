class Vas::OrderDetail < ActiveRecord::Base
  belongs_to :vas_order, class_name: Vas::Order, foreign_key: "vas_order_id"
end
