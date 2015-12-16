class MigrateOrderDetailReplenishCreditsToCreditModel < ActiveRecord::Migration
  def change
    OrderDetail::ReplenishCredits.all.each do |od_credit|
      order = od_credit.order
      c = Credit.new({
        partner: order.partner,
        type: 'Credit::BankReplenish',
        status: 'complete',
        amount: od_credit.price,
        remarks: od_credit.remarks,
        credited_at: order.ordered_at
        }, order.partner)
      c.save
    end
  end
end
