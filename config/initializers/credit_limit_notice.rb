config = Rails.application.config_for(:credit_limit_notice).with_indifferent_access

Rails.configuration.activate_credit_validation = config[:activate_credit_validation]
Rails.configuration.default_credit_limit       = config[:default_credit_limit]
Rails.configuration.cl_notice_active           = config[:cl_notice_active]
Rails.configuration.cl_notice_threshold        = config[:cl_notice_threshold]
Rails.configuration.first_notice               = config[:first_notice]
Rails.configuration.second_notice              = config[:second_notice]
Rails.configuration.third_notice               = config[:third_notice]
