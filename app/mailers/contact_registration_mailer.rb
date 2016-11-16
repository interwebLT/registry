class ContactRegistrationMailer < ApplicationMailer
  def non_ascii_notification partner, handle, contact
    @partner = partner
    @contact = contact
    @handle  = handle
    mail to: @partner.email, bcc: ["registrar@dot.ph"], subject: "Contact Registration Notice"
  end
end