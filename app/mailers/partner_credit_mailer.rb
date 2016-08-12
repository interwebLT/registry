class PartnerCreditMailer < ApplicationMailer
  def credit_balance_below_threshold order
    @partner = order.partner
    mail to: @partner.email, subject: "Low Balance Notice"
  end

  def credit_balance_notification order
    @partner = order.partner
    mail to: @partner.email, subject: "Credit Balance Notice"
  end

  def credit_limit_notice order, notice_level
    @partner = order.partner
    @order = order

    case notice_level
      when "first"
        if @partner.preferences["cl_second_notice"].nil?
          mail to: @partner.email, subject: "Credit Limit Notice"
        end
      when "second"
        if @partner.preferences["cl_third_notice"].nil?
          mail to: @partner.email, subject: "Credit Limit Notice"
        end
      when "third"
        mail to: @partner.email, subject: "Credit Limit Notice"
    end
  end
end
