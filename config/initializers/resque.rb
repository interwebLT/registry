config = Rails.application.config_for(:resque).with_indifferent_access

require 'resque'

Resque.redis = "#{config[:host]}:#{config[:port]}"
