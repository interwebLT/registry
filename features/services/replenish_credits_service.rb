def replenish_credits partner: nil
  json_request = {
    currency_code: 'USD',
    ordered_at: Time.now,
    order_details: [
      type: 'credits',
      credits: 100,
      remarks: 'test remark'
    ]
  }

  json_request[:partner] = NON_ADMIN_PARTNER if @current_user.admin?
  json_request[:partner] = partner if partner
  json_request.delete(:partner) if partner == NO_PARTNER

  post credits_url, json_request
end

def assert_balance_changed
  partner = Partner.find_by name: NON_ADMIN_PARTNER
  partner.current_balance.to_i.must_equal 100
end