def replenish_credits_via_checkout
  to = Rails.configuration.checkout_endpoint + "/charges/#{authcode}"
  stub_request(:get, to).with(:headers => checkout_headers)
                        .to_return(status: 200, body: checkout_response.to_json)

  json_request = {
    type: 'card_credit',
    partner: NON_ADMIN_PARTNER,
    amount_currency: 'USD',
    amount: 100,
    credited_at: Time.now,
    verification_code: authcode,
    remarks: 'Replenish Credit'
  }

  post credits_url, json_request
end

def authcode
  'pay_tok_A0DD19FA-6188-4EFE-B54C-6EBD4E97D6EE'
end

def checkout_response
  {
    responseMessage: 'Approved'  
  }
end

def checkout_headers
  {
    "Content-Type" => "application/json",
    "Authorization" => Rails.configuration.checkout_sk
  }
end