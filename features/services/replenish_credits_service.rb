def replenish_credits partner: nil
  json_request = {
    amount_currency: 'USD',
    type: 'card_credit',
    amount: 100,
    fee: 5,
    fee_currency: 'USD',
    remarks: 'test remark'
  }

  json_request[:partner] = NON_ADMIN_PARTNER if @current_user.admin?
  json_request[:partner] = partner if partner
  json_request.delete(:partner) if partner == NO_PARTNER

  post credits_url, json_request
end

def assert_balance_is_money_type
  partner = Partner.find_by name: NON_ADMIN_PARTNER
  partner.current_balance.must_be_kind_of(Money)
end

def assert_balance_changed
  partner = Partner.find_by name: NON_ADMIN_PARTNER
  partner.current_balance.to_i.must_equal 100
end