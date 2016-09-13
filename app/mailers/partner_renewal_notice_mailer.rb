class PartnerRenewalNoticeMailer < ApplicationMailer
  def send_renewal_notice partner, domains, days
    @partner = partner
    @domains  = domains
    @days    = days

    if days == 0
      subject = "#{@partner.name} - domain expired today"
      @remaining_days = "expires today"
    else
      subject = "#{@partner.name} - #{days} days before expiration"
      @remaining_days = "will expire in #{days} days"
    end
    mail to: partner.email, subject: subject
  end

  def send_deleted_notice partner, domains
    @partner = partner
    @domains  = domains
    mail to: partner.email, subject: "#{@partner.name} - Deleted in the Database"
  end
end
