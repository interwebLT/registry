config = Rails.application.config_for(:credit_limit_notice).with_indifferent_access

Rails.configuration.first_notice  = config[:first_notice]
Rails.configuration.second_notice = config[:second_notice]
Rails.configuration.third_notice  = config[:third_notice]
