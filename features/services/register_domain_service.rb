BLANK_REGISTERED_AT = nil
REGISTERED_AT = '2015-01-01 00:00'.in_time_zone

def register_domain partner: nil,
                    name: DOMAIN,
                    period: 2,
                    registrant: CONTACT_HANDLE,
                    registered_at: REGISTERED_AT
  json_request = {
    currency_code: 'USD',
    ordered_at: registered_at,
    order_details: [
      type: 'domain_create',
      domain: name,
      authcode: AUTHCODE,
      period: period,
      registrant_handle: registrant
    ]
  }

  json_request[:partner] = NON_ADMIN_PARTNER if @current_user.admin?
  json_request[:partner] = partner if partner
  json_request.delete(:partner) if partner == NO_PARTNER

  post orders_url, json_request
end

def assert_completed_register_domain_response domain: DOMAIN, object: product
  assert_register_domain_response domain: domain, status: 'complete', object: object
end

def assert_register_domain_response domain: nil,
                                    partner: 'alpha',
                                    status: 'complete',
                                    registrant: CONTACT_HANDLE,
                                    object: product
  assert_response_status_must_be_created

  domain_name = domain || DOMAIN

  expected_response = {
    id: 1,
    partner: partner,
    order_number: 1,
    total_price: 70.00,
    fee: 0.00,
    ordered_at: '2015-01-01T00:00:00Z',
    status: status,
    currency_code: 'USD',
    order_details: [
      {
        type: 'domain_create',
        price: 70.00,
        domain: domain_name,
        object: object,
        authcode: AUTHCODE,
        period: 2,
        registrant_handle: registrant
      }
    ]
  }

  json_response.must_equal expected_response
end

def register_domain_order_must_be_created
  # assert_register_domain_response status: 'pending', object: nil
  assert_register_domain_response status: 'complete', object: {:id=>1, :type=>"domain", :name=>"domain.ph"}
  order_must_be_created status: 'complete', type: OrderDetail::RegisterDomain

  # order_must_be_created status: 'pending', type: OrderDetail::RegisterDomain
end

def product id: 1, type: 'domain', name: 'domain.ph'
  {
    id: id,
    type: type,
    name: name
  }
end
