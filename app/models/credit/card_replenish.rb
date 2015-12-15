class Credit::CardReplenish < Credit
  
  def self.build params, partner
    credit = self.new
    credit.amount = params[:amount].money
    credit.verification_code = params[:verification_code]
    credit.credited_at = params[:credited_at]
    credit.remarks = params[:remarks]

    credit
  end

end