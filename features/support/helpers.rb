def assert_fee_deducted amount
  ledger = @current_partner.ledgers.last

  ledger.wont_be_nil
  ledger.activity_type.must_equal 'use'
  ledger.amount.must_equal (amount * -1)
end

def default_headers
  {
    'Accept'        => 'application/json',
    'Content-Type'  => 'application/json'
  }
end

def headers
  default_headers.tap do |headers|
    headers['Authorization'] = 'Token token=alpha'
  end
end
