config = Rails.application.config_for(:cocca).with_indifferent_access

Rails.configuration.cocca_host = config[:host]