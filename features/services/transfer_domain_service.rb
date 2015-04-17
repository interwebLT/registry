def transfer_domain
  json_request = {
    partner: @current_partner.name,
    currency_code: 'USD',
    order_details: [
      {
        type: 'transfer_domain',
        domain: DOMAIN
      }
    ]
  }

  post orders_url, json_request
end

def assert_domain_transferred
  saved_domain.partner.name.must_equal NON_ADMIN_PARTNER

  latest_activity = saved_domain.domain_activities.last
  latest_activity.must_be_kind_of ObjectActivity::Transfer
  latest_activity.losing_partner.name.must_equal OTHER_PARTNER
end
