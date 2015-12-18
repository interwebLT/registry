def assert_fee_deducted amount
  ledger = @current_partner.ledgers.last

  ledger.wont_be_nil
  ledger.activity_type.must_equal 'use'
  ledger.amount.must_equal (amount * -1)
end

def build_request scenario:, resource:, action:
  request = "#{resource.to_s}/"

  if scenario.include? 'for another partner'
    request << 'admin '
    scenario.sub! 'for another partner', ''
  end

  request << "#{action.to_s} #{scenario.downcase} request"
  request.gsub! '  ', ' '
  request.gsub! '-', '_'
  request.gsub! ' ', '_'

  request
end

def headers
  {
    'Accept'        => 'application/json',
    'Authorization' => 'Token token=alpha',
    'Content-Type'  => 'application/json'
  }
end
