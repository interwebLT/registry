BLANK_DOMAIN_NAME = ''
INVALID_PERIOD = 11
BLANK_PERIOD = nil
BLANK_REGISTRANT = nil
BLANK_REGISTERED_AT = nil
BLANK_PARTNER = nil
TWO_LEVEL_DOMAIN = 'test.com.ph'
REGISTERED_AT = '2015-01-01 00:00'.in_time_zone

def register_domain partner: nil,
                    name: DOMAIN,
                    period: 2,
                    registrant: CONTACT_HANDLE,
                    registered_at: REGISTERED_AT
  json_request = {
    currency_code: 'USD',
    order_details: [
      type: 'domain_create',
      domain: name,
      authcode: AUTHCODE,
      period: period,
      registrant_handle: registrant,
      registered_at: registered_at
    ]
  }

  json_request[:partner] = NON_ADMIN_PARTNER if @current_user.admin?
  json_request[:partner] = partner if partner
  json_request.delete(:partner) if partner == NO_PARTNER

  post orders_url, json_request
end

def assert_completed_register_domain_response domain: DOMAIN
  assert_register_domain_response partner: NON_ADMIN_PARTNER, domain: domain, status: 'complete'
end

def assert_register_domain_response domain: nil,
                                    partner: 'alpha',
                                    status: 'complete',
                                    registrant: CONTACT_HANDLE
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
        authcode: AUTHCODE,
        period: 2,
        registrant_handle: registrant,
        registered_at: '2015-01-01T00:00:00Z'
      }
    ]
  }

  json_response.must_equal expected_response
end

def create_order json_request: {}
  post orders_url, json_request
end

def register_domain_order_must_be_created
  assert_register_domain_response status: 'pending'

  order_must_be_created status: 'pending', type: OrderDetail::RegisterDomain
end

def order_must_be_created(status:, type:)
  saved_order = Order.last
  saved_order.status.must_equal status
  saved_order.order_details.first.must_be_kind_of type
end

def view_orders
  create :pending_register_domain_order,  partner: @current_partner
  create :register_domain_order, partner: @current_partner
  create :renew_domain_order, partner: @current_partner
  create :replenish_credits_order, partner: @current_partner
  create :transfer_domain_order, partner: @current_partner

  get orders_path
end

def view_latest_orders
  create :pending_register_domain_order, ordered_at: Time.now
  create :register_domain_order, ordered_at: Time.now
  create :renew_domain_order, ordered_at: Time.now
  create :replenish_credits_order, ordered_at: Time.now
  create :transfer_domain_order, ordered_at: Time.now

  get orders_path
end

def assert_orders_displayed
  assert_response_status_must_be_ok

  json_response.must_equal orders_response
end

def renew_domain partner: nil
  json_request = {
    currency_code: 'USD',
    order_details: [
      type: 'domain_renew',
      domain: DOMAIN,
      period: 2,
      renewed_at: REGISTERED_AT + 1
    ]
  }

  json_request[:partner] = NON_ADMIN_PARTNER if @current_user.admin?
  json_request[:partner] = partner if partner
  json_request.delete(:partner) if partner == NO_PARTNER

  post orders_url, json_request
end

def assert_renew_domain_order_created
  order_must_be_created status: 'pending', type: OrderDetail::RenewDomain
end

def assert_pending_orders_not_displayed
  json_response.count.must_equal 3
end

def assert_latest_orders_displayed
  json_response.must_equal latest_orders_response
end

def assert_domain_must_be_renewed
  new_expires_at = REGISTERED_AT + 2.year

  saved_domain.expires_at.must_equal new_expires_at
end

def assert_renew_domain_fee_must_be_deducted
  credits = @current_partner.credits.last

  credits.wont_be_nil
  credits.activity_type = 'use'
  credits.credits = -30.00.money
end

private

def orders_response
  [
    {
      id: 1,
      partner: 'alpha',
      order_number: 1,
      total_price: 35.00,
      fee: 0.00,
      ordered_at: '2015-01-01T00:00:00Z',
      status: 'complete',
      currency_code: 'USD',
      order_details: [
        {
          type: 'domain_create',
          price: 35.00,
          domain: 'domains.ph',
          authcode: 'ABC123',
          period: 2,
          registrant_handle: 'domains_r',
          registered_at: '2015-02-17T00:00:00Z'
        }
      ]
    },
    {
      id: 2,
      partner: 'alpha',
      order_number: 2,
      total_price: 35.00,
      fee: 0.00,
      ordered_at: '2015-01-01T00:00:00Z',
      status: 'complete',
      currency_code: 'USD',
      order_details: [
        {
          type: 'domain_renew',
          price: 35.00,
          domain: 'domain.ph',
          period: 1,
          renewed_at: '2015-02-14T01:01:00Z'
        }
      ]
    },
    {
      id: 3,
      partner: 'alpha',
      order_number: 3,
      total_price: 15.00,
      fee: 0.00,
      ordered_at: '2015-01-01T00:00:00Z',
      status: 'complete',
      currency_code: 'USD',
      order_details: [
        {
          type: 'domain_transfer',
          price: 15.00,
          domain: 'domain.ph'
        }
      ]
    }
  ]
end

def latest_orders_response
  [
    {
      id: 1,
      partner: 'alpha',
      order_number: 1,
      total_price: 15.00,
      fee: 0.00,
      ordered_at: '2015-01-01T00:00:00Z',
      status: 'complete',
      currency_code: 'USD',
      order_details: [
        {
          type: 'domain_transfer',
          price: 15.00,
          domain: 'domain.ph'
        }
      ]
    },
    {
      id: 2,
      partner: 'alpha',
      order_number: 2,
      total_price: 150.00,
      fee: 0.00,
      ordered_at: '2015-01-01T00:00:00Z',
      status: 'complete',
      currency_code: 'USD',
      order_details: [
        {
          type: 'credits',
          price: 150.00
        }
      ]
    },
    {
      id: 3,
      partner: 'alpha',
      order_number: 3,
      total_price: 35.00,
      fee: 0.00,
      ordered_at: '2015-01-01T00:00:00Z',
      status: 'complete',
      currency_code: 'USD',
      order_details: [
        {
          type: 'domain_renew',
          price: 35.00,
          domain: 'domain.ph',
          period: 1,
          renewed_at: '2015-02-14T01:01:00Z'
        }
      ]
    },
    {
      id: 4,
      partner: 'alpha',
      order_number: 4,
      total_price: 35.00,
      fee: 0.00,
      ordered_at: '2015-01-01T00:00:00Z',
      status: 'complete',
      currency_code: 'USD',
      order_details: [
        {
          type: 'domain_create',
          price: 35.00,
          domain: 'domains.ph',
          authcode: 'ABC123',
          period: 2,
          registrant_handle: 'domains_r',
          registered_at: '2015-02-17T00:00:00Z'
        }
      ]
    },
    {
      id: 5,
      partner: 'alpha',
      order_number: 5,
      total_price: 35.00,
      fee: 0.00,
      ordered_at: '2015-01-01T00:00:00Z',
      status: 'pending',
      currency_code: 'USD',
      order_details: [
        {
          type: 'domain_create',
          price: 35.00,
          domain: 'domains.ph',
          authcode: 'ABC123',
          period: 2,
          registrant_handle: 'domains_r',
          registered_at: '2015-02-17T00:00:00Z'
        }
      ]
    }
  ]
end
