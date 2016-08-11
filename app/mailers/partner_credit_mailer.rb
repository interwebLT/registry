class PartnerCreditMailer < ApplicationMailer
  def credit_balance_below_100_notification order
    @partner = order.partner
    mail to: order.partner.email, subject: "Low Balance Notice"
  end

  def credit_balance_notification order
    @partner = order.partner
    mail to: order.partner.email, subject: "Credit Balance Notice"
  end

  def credit_limit_notice order
    @partner = order.partner
    @order = order
    mail to: order.partner.email, subject: "Credit Limit Notice"
  end
end
