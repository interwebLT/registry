class PartnerBillingMailer < ApplicationMailer
  def billing_statement partner, credits, orders
    @partner = partner
    @credit  = credits
    @orders  = orders
    mail to: partner.email, subject: "Billing Statement"
  end
end
