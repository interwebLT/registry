class MigrateAllReplenishCredits < ActiveRecord::Migration
  def change
    Credit.where(:type => 'Credit::BankReplenish').delete_all
    OrderDetail::ReplenishCredits.all.each do |od_credit|
      order = od_credit.order
      remarks = od_credit.remarks.blank? ? '-' : od_credit.remarks
      
      c = Credit.new({
        partner: order.partner,
        type: 'Credit::BankReplenish',
        status: 'complete',
        amount: od_credit.price,
        remarks: remarks,
        credited_at: order.ordered_at
        }, order.partner)
      c.save!
      
      ledger = Ledger.where(:order => order).first
      if ledger
        ledger.credit = c
        ledger.save!
      end
    end
  end
end
