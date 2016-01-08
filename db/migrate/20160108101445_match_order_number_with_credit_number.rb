class MatchOrderNumberWithCreditNumber < ActiveRecord::Migration
  def change
    OrderDetail::ReplenishCredits.all.each do |order_detail|
      credit = Credit.find_by credited_at: order_detail.order.ordered_at

      credit.update! credit_number: order_detail.order.order_number
    end
  end
end
