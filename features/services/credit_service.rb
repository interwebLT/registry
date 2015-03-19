def credit_exists
  create :pending_replenish_credits_order, partner: @current_partner
  create :replenish_credits_order, partner: @current_partner
end

def view_credits
  get credits_path
end

def assert_credits_displayed
  assert_response_status_must_be_ok

  expected_response = [
    id: 1,
    partner: 'alpha',
    order_number: 1,
    credits: 150.00,
    credited_at: '2015-02-27T14:30:00Z',
    created_at: '2015-01-01T00:00:00Z',
    updated_at: '2015-01-01T00:00:00Z',
  ]

  json_response.must_equal expected_response
end

def assert_pending_credits_not_displayed
  json_response.count.must_equal 1
end
