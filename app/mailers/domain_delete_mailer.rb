class DomainDeleteMailer < ApplicationMailer
  def send_notice domain_name, partner_name, email
    @domain_name  = domain_name
    @partner_name = partner_name
    mail to: email, subject: "Domain Deleted Notice"
  end
end
