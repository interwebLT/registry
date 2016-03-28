class Credit::CardReplenish < Credit
  
  def self.build params, partner
    credit = self.new
    credit.amount = params[:amount].money
    credit.fee = Float(params[:fee]).money
    credit.verification_code = params[:verification_code]
    credit.credited_at = params[:credited_at]
    credit.remarks = params[:remarks]

    credit
  end
  
  def self.execute partner:, credit:, fee:, remarks:, at: Time.current
    saved_partner = Partner.find_by! name: partner
    amount = credit.money

    credit = self.new partner: saved_partner,
                      amount: amount,
                      fee: fee,
                      credited_at: at,
                      remarks: remarks

    credit.save!
    credit.complete!
  end

end