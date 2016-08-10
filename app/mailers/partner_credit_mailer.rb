class PartnerCreditMailer < ApplicationMailer
  def credit_balance_notification order
    @partner = order.partner
    mail to: order.partner.email, subject: "Partner Credit Balance"
  end

  def credit_limit_notice order
    @partner = order.partner
    @order = order
    mail to: order.partner.email, subject: "Partner Credit Limit Reminder"
  end
end
