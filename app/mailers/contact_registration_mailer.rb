class ContactRegistrationMailer < ApplicationMailer
  def non_ascii_notification partner, contact
    @partner = partner
    @contact = contact
    mail to: @partner.email, bcc: ["helpdesk@dot.ph"], subject: "Contact Registration Notice"
  end
end