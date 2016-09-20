class ApplicationMailer < ActionMailer::Base
  helper MailerHelper
  default from: '"dotPH Registrar" <registrar@dot.ph>'
  layout 'mailer'
end
