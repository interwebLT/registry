def credit_exists
  create :pending_replenish_credits, partner: @current_partner
  create :replenish_credits, partner: @current_partner
end

def view_credits
  get credits_path
end

def assert_credits_displayed
  assert_response_status_must_be_ok

  expected_response = [{
    id: 1,
    partner_id: @current_partner.id,
    partner: 'alpha',
    credit_number: /[a-zA-Z0-9]{10}/,
    amount: 150.0,
    fee: 7.5,
    credited_at: '2015-02-27T14:30:00Z',
    created_at: '2015-01-01T00:00:00Z',
    updated_at: '2015-01-01T00:00:00Z',
    verification_code: nil,
    type: "Credit::BankReplenish",
    status: "complete"
  }]

  json_response.must_match_json_expression expected_response
end

def assert_pending_credits_not_displayed
  json_response.count.must_equal 1
end
