config = Rails.application.config_for(:registry).with_indifferent_access

Rails.configuration.multi_user_mode = config[:multi_user]