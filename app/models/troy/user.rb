class Troy::User < ActiveRecord::Base
  self.table_name = 'troy_users'
  self.inheritance_column = :_type_disabled

  scope :partners, -> {where("trim(type) = ? and userid not like ? and userid not like ?", "partner", "cp%", "tp%")}

  def self.generate_remaining_balance
    @troy_partners = Troy::User.partners

    @troy_partners.each do |troy_partner|
      partner_current_balance  = 0
      partner_credit_available = 0
      partner_credit_used      = 0
      unless Troy::CreditAvailable.where("userrefkey=?", troy_partner.userrefkey).first.nil?
        credits = Troy::CreditAvailable.where("userrefkey=?", troy_partner.userrefkey).map{|credit| credit.numcredits} - [nil]
        partner_credit_available = credits.sum.to_f
      end

      unless Troy::Creditused.where("userrefkey=?", troy_partner.userrefkey).first.nil?
        used = Troy::Creditused.where("userrefkey=?", troy_partner.userrefkey).map{|credit| credit.numcredits} - [nil]
        partner_credit_used = used.sum.to_f
      end
      partner_current_balance = partner_credit_available - partner_credit_used

      if !partner_current_balance.nil?
        balance = "Current Balance for Partner #{troy_partner.userid} -- #{partner_current_balance.money}"
        log ||= Logger.new("#{Rails.root}/log/Troy_Partners_Current_Balances.log")
        log.info(balance) unless balance.nil?
        puts "#{troy_partner.userid} balance was logged."
      end
    end
    puts "Troy Partner Balances generated. Please check log file on #{Rails.root}/log/Troy_Partners_Current_Balances.log"
  end
end
