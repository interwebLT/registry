EXPIRES_AT = '2017-01-01 00:00'.in_time_zone

MIGRATE_DOMAIN_PARAMS = {
  'no domain name'                  => { domain: nil },
  'no registrant handle'            => { registrant_handle: nil },
  'no registered at'                => { registered_at: nil },
  'no expires at'                   => { expires_at: nil },
  'expires at before registered at' => { expires_at: '2000-01-01T00:00:00Z' }
}

def migrate_domain scenario: nil
  json_request = {
    partner: NON_ADMIN_PARTNER,
    currency_code: 'USD',
    order_details: [
      type: 'migrate_domain',
      domain: DOMAIN,
      authcode: 'ABC123',
      registrant_handle: CONTACT_HANDLE,
      registered_at: REGISTERED_AT,
      expires_at: EXPIRES_AT
    ]
  }

  json_request[:order_details].first.merge!(MIGRATE_DOMAIN_PARAMS[scenario]) if scenario

  post migrations_url, json_request
end

def assert_completed_migrate_domain_response
  assert_response_status_must_be_created

  expected_response = {
    id: 1,
    partner: NON_ADMIN_PARTNER,
    order_number: 1,
    total_price: 0.00,
    fee: 0.00,
    ordered_at: '2015-01-01T00:00:00Z',
    status: 'complete',
    currency_code: 'USD',
    order_details: [
      {
        type: 'migrate_domain',
        price: 0.00,
        domain: DOMAIN,
        authcode: 'ABC123',
        registrant_handle: CONTACT_HANDLE,
        registered_at: REGISTERED_AT.iso8601,
        expires_at: EXPIRES_AT.iso8601
      }
    ]
  }

  json_response.must_equal expected_response
end