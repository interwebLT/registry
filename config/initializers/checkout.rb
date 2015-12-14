config = Rails.application.config_for(:checkout).with_indifferent_access

Rails.configuration.checkout_sk = config[:secret_key]
Rails.configuration.checkout_pk = config[:public_key]
Rails.configuration.checkout_endpoint = config[:endpoint]
