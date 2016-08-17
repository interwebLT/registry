config = Rails.application.config_for(:api).with_indifferent_access

Rails.configuration.api_url = config[:url]