class PartnerInvoiceMailer < ApplicationMailer
  def invoice_letter partner, orders
    @partner = partner
    # @credit  = credits
    @orders  = orders
    mail to: partner.email, subject: "Monthly Invoice"
  end
end
