class DomainDeleteMailer < ApplicationMailer
  def send_notice domain_name, partner_name
    @domain_name  = domain_name
    @partner_name = partner_name
    ["reynan@dot.ph", "jm.mendoza@dot.ph", "ca.galamay@dot.ph"].each do |email|
      mail to: email, subject: "Domain Deleted Notice"
    end
  end
end
