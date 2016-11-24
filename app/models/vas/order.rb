class Vas::Order < ActiveRecord::Base
  has_many :vas_order_details, class_name: Vas::OrderDetail, foreign_key: "vas_order_id", dependent: :destroy
end
