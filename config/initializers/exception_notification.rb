config = Rails.application.config_for(:exception_notification).with_indifferent_access

require 'exception_notification/rails'

require 'resque/failure/multiple'
require 'resque/failure/redis'
require 'exception_notification/resque'

Resque::Failure::Multiple.classes = [Resque::Failure::Redis, ExceptionNotification::Resque]
Resque::Failure.backend = Resque::Failure::Multiple

ExceptionNotification.configure do |c|
  c.add_notifier :email, {
    sender_address: config[:sender_address],
    exception_recipients: config[:exception_recipients]
  }
end if Rails.env.production?
