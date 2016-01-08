config = Rails.application.config_for(:exception_notification).with_indifferent_access

require 'exception_notification/rails'

require 'exception_notification/sidekiq'

ExceptionNotification.configure do |c|
  c.add_notifier :email, {
    sender_address: config[:sender_address],
    exception_recipients: config[:exception_recipients]
  }
end if Rails.env.production?
