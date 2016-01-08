config = Rails.application.config_for(:sidekiq).with_indifferent_access

Sidekiq.configure_server do |c|
  c.redis = { url: config[:url] }
end

Sidekiq.configure_client do |c|
  c.redis = { url: config[:url] }
end
