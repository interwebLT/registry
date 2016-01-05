config = Rails.application.config_for('cocca-api').with_indifferent_access

Rails.configuration.x.cocca_api_host = config[:host]
Rails.configuration.x.cocca_api_sync = config[:enable_sync]
