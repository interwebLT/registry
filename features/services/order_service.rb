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
    ordered_at: '2015-08-07T16:00:00Z',
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

def assert_completed_register_domain_response domain: DOMAIN, object: product
  assert_register_domain_response partner: alpha_partner(credits: -70.0), domain: domain, status: 'complete', object: object
end

def assert_register_domain_response domain: nil,
                                    partner: alpha_partner,
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
  assert_register_domain_response partner: nature_partner, status: 'pending', object: nil

  order_must_be_created status: 'pending', type: OrderDetail::RegisterDomain
end

def order_must_be_created(status:, type:)
  saved_order = Order.last
  saved_order.status.must_equal status
  saved_order.order_details.first.must_be_kind_of type
end

def view_orders
  create :pending_register_domain_order,  partner: @current_partner
  create :register_domain_order,          partner: @current_partner
  create :renew_domain_order,             partner: @current_partner
  create :replenish_credits_order,        partner: @current_partner
  create :transfer_domain_order,          partner: @current_partner

  refund_order = create :refund_order,    partner: @current_partner
  refund_order.order_details.first.refunded_order_detail.order.partner = @current_partner
  refund_order.order_details.first.refunded_order_detail.order.save!

  get orders_path
end

def view_latest_orders
  create :pending_register_domain_order,  ordered_at: Time.now
  create :register_domain_order,          ordered_at: Time.now
  create :renew_domain_order,             ordered_at: Time.now
  create :replenish_credits_order,        ordered_at: Time.now
  create :transfer_domain_order,          ordered_at: Time.now
  create :refund_order,                   ordered_at: Time.now

  get orders_path
end

def assert_orders_displayed
  assert_response_status_must_be_ok

  json_response.must_equal orders_response
end

def assert_pending_orders_not_displayed
  json_response.count.must_equal 5
end

def assert_latest_orders_displayed
  json_response.must_equal latest_orders_response
end

def assert_refunded_orders_displayed
  json_response.count.must_equal 5
end

private

def orders_response
  [
    {
      id: 1,
      partner:     {
        id: 1,
        name: 'alpha',
        organization: 'Company',
        credits: 0.00,
        site: 'http://alpha.org',
        nature: 'Nature',
        representative: 'Representative',
        position: 'Position',
        street: 'Street',
        city: 'City',
        state: 'State',
        postal_code: '1234',
        country_code: 'PH',
        phone: '+63.21234567',
        fax: '+63.21234567',
        email: 'alpha@alpha.org',
        local: true,
        admin: false
      },
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
          object: nil,
          authcode: 'ABC123',
          period: 2,
          registrant_handle: 'domains_r',
          registered_at: '2015-02-17T00:00:00Z'
        }
      ]
    },
    {
      id: 2,
      partner:     {
        id: 2,
        name: 'alpha',
        organization: 'Company',
        credits: 0.00,
        site: 'http://alpha.org',
        nature: 'Nature',
        representative: 'Representative',
        position: 'Position',
        street: 'Street',
        city: 'City',
        state: 'State',
        postal_code: '1234',
        country_code: 'PH',
        phone: '+63.21234567',
        fax: '+63.21234567',
        email: 'alpha@alpha.org',
        local: true,
        admin: false
      },
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
          object: nil,
          period: 1
        }
      ]
    },
    {
      id: 3,
      partner:     {
        id: 3,
        name: 'alpha',
        organization: 'Company',
        credits: 0.00,
        site: 'http://alpha.org',
        nature: 'Nature',
        representative: 'Representative',
        position: 'Position',
        street: 'Street',
        city: 'City',
        state: 'State',
        postal_code: '1234',
        country_code: 'PH',
        phone: '+63.21234567',
        fax: '+63.21234567',
        email: 'alpha@alpha.org',
        local: true,
        admin: false
      },
      order_number: 3,
      total_price: 15.00,
      fee: 0.00,
      ordered_at: '2015-01-01T00:00:00Z',
      status: 'complete',
      currency_code: 'USD',
      order_details: [
        {
          type: 'transfer_domain',
          price: 15.00,
          domain: 'domain.ph',
          object: nil,
        }
      ]
    },
    {
      id: 4,
      partner:     {
        id: 4,
        name: 'alpha',
        organization: 'Company',
        credits: 0.00,
        site: 'http://alpha.org',
        nature: 'Nature',
        representative: 'Representative',
        position: 'Position',
        street: 'Street',
        city: 'City',
        state: 'State',
        postal_code: '1234',
        country_code: 'PH',
        phone: '+63.21234567',
        fax: '+63.21234567',
        email: 'alpha@alpha.org',
        local: true,
        admin: false
      },
      order_number: 4,
      total_price: 35.00,
      fee: 0.00,
      ordered_at: '2015-01-01T00:00:00Z',
      status: 'reversed',
      currency_code: 'USD',
      order_details: [
        {
          type: 'domain_renew',
          price: 35.00,
          domain: 'domain.ph',
          object: nil,
          period: 1
        }
      ]
    },
    {
      id: 5,
      partner:     {
        id: 5,
        name: 'alpha',
        organization: 'Company',
        credits: 0.00,
        site: 'http://alpha.org',
        nature: 'Nature',
        representative: 'Representative',
        position: 'Position',
        street: 'Street',
        city: 'City',
        state: 'State',
        postal_code: '1234',
        country_code: 'PH',
        phone: '+63.21234567',
        fax: '+63.21234567',
        email: 'alpha@alpha.org',
        local: true,
        admin: false
      },
      order_number: 5,
      total_price: -35.00,
      fee: 0.00,
      ordered_at: '2015-01-01T00:00:00Z',
      status: 'complete',
      currency_code: 'USD',
      order_details: [
        {
          type: 'refund',
          price:  -35.00,
          refunded_order_detail: {
            type: 'domain_renew',
            price: 35.00,
            domain: 'domain.ph',
            object: nil,
            period: 1
          }
        }
      ]
    }
  ]
end

def latest_orders_response
  [
    {
      id: 1,
      partner:     {
        id: 1,
        name: 'alpha',
        organization: 'Company',
        credits: 0.00,
        site: 'http://alpha.ph',
        nature: 'Alpha Business',
        representative: 'Alpha Guy',
        position: 'Position',
        street: 'Alpha Street',
        city: 'Alpha City',
        state: 'Alpha State',
        postal_code: '1234',
        country_code: 'PH',
        phone: '+63.1234567',
        fax: '+63.1234567',
        email: 'alpha@alpha.ph',
        local: true,
        admin: false
      },
      order_number: 1,
      total_price: -35.00,
      fee: 0.00,
      ordered_at: '2015-01-01T00:00:00Z',
      status: 'complete',
      currency_code: 'USD',
      order_details: [
        {
          type: 'refund',
          price:  -35.00,
          refunded_order_detail: {
            type: 'domain_renew',
            price: 35.00,
            domain: 'domain.ph',
            object: nil,
            period: 1
          }
        }
      ]
    },
    {
      id: 2,
      partner:     {
        id: 2,
        name: 'alpha',
        organization: 'Company',
        credits: 0.00,
        site: 'http://alpha.ph',
        nature: 'Alpha Business',
        representative: 'Alpha Guy',
        position: 'Position',
        street: 'Alpha Street',
        city: 'Alpha City',
        state: 'Alpha State',
        postal_code: '1234',
        country_code: 'PH',
        phone: '+63.1234567',
        fax: '+63.1234567',
        email: 'alpha@alpha.ph',
        local: true,
        admin: false
      },
      order_number: 2,
      total_price: 15.00,
      fee: 0.00,
      ordered_at: '2015-01-01T00:00:00Z',
      status: 'complete',
      currency_code: 'USD',
      order_details: [
        {
          type: 'transfer_domain',
          price: 15.00,
          domain: 'domain.ph',
          object: nil
        }
      ]
    },
    {
      id: 3,
      partner:     {
        id: 3,
        name: 'alpha',
        organization: 'Company',
        credits: 0.00,
        site: 'http://alpha.ph',
        nature: 'Alpha Business',
        representative: 'Alpha Guy',
        position: 'Position',
        street: 'Alpha Street',
        city: 'Alpha City',
        state: 'Alpha State',
        postal_code: '1234',
        country_code: 'PH',
        phone: '+63.1234567',
        fax: '+63.1234567',
        email: 'alpha@alpha.ph',
        local: true,
        admin: false
      },
      order_number: 3,
      total_price: 150.00,
      fee: 0.00,
      ordered_at: '2015-01-01T00:00:00Z',
      status: 'complete',
      currency_code: 'USD',
      order_details: [
        {
          type: 'credits',
          price: 150.00,
          object: nil
        }
      ]
    },
    {
      id: 4,
      partner:     {
        id: 4,
        name: 'alpha',
        organization: 'Company',
        credits: 0.00,
        site: 'http://alpha.ph',
        nature: 'Alpha Business',
        representative: 'Alpha Guy',
        position: 'Position',
        street: 'Alpha Street',
        city: 'Alpha City',
        state: 'Alpha State',
        postal_code: '1234',
        country_code: 'PH',
        phone: '+63.1234567',
        fax: '+63.1234567',
        email: 'alpha@alpha.ph',
        local: true,
        admin: false
      },
      order_number: 4,
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
          object: nil,
          period: 1
        }
      ]
    },
    {
      id: 5,
      partner:     {
        id: 5,
        name: 'alpha',
        organization: 'Company',
        credits: 0.00,
        site: 'http://alpha.ph',
        nature: 'Alpha Business',
        representative: 'Alpha Guy',
        position: 'Position',
        street: 'Alpha Street',
        city: 'Alpha City',
        state: 'Alpha State',
        postal_code: '1234',
        country_code: 'PH',
        phone: '+63.1234567',
        fax: '+63.1234567',
        email: 'alpha@alpha.ph',
        local: true,
        admin: false
      },
      order_number: 5,
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
          object: nil,
          authcode: 'ABC123',
          period: 2,
          registrant_handle: 'domains_r',
          registered_at: '2015-02-17T00:00:00Z'
        }
      ]
    },
    {
      id: 6,
      partner:     {
        id: 6,
        name: 'alpha',
        organization: 'Company',
        credits: 0.00,
        site: 'http://alpha.ph',
        nature: 'Alpha Business',
        representative: 'Alpha Guy',
        position: 'Position',
        street: 'Alpha Street',
        city: 'Alpha City',
        state: 'Alpha State',
        postal_code: '1234',
        country_code: 'PH',
        phone: '+63.1234567',
        fax: '+63.1234567',
        email: 'alpha@alpha.ph',
        local: true,
        admin: false
      },
      order_number: 6,
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
          object: nil,
          authcode: 'ABC123',
          period: 2,
          registrant_handle: 'domains_r',
          registered_at: '2015-02-17T00:00:00Z'
        }
      ]
    },
    {
      id: 7,
      partner:     {
        id: 7,
        name: 'alpha',
        organization: 'Company',
        credits: 0.00,
        site: 'http://alpha.ph',
        nature: 'Alpha Business',
        representative: 'Alpha Guy',
        position: 'Position',
        street: 'Alpha Street',
        city: 'Alpha City',
        state: 'Alpha State',
        postal_code: '1234',
        country_code: 'PH',
        phone: '+63.1234567',
        fax: '+63.1234567',
        email: 'alpha@alpha.ph',
        local: true,
        admin: false
      },
      order_number: 7,
      total_price: 35.00,
      fee: 0.00,
      ordered_at: '2015-01-01T00:00:00Z',
      status: 'reversed',
      currency_code: 'USD',
      order_details: [
        {
          type: 'domain_renew',
          price: 35.00,
          domain: 'domain.ph',
          object: nil,
          period: 1
        }
      ]
    }
  ]
end

def nature_partner
  {
    id: 1,
    name: 'alpha',
    organization: 'Company',
    credits: 0.00,
    site: 'http://alpha.org',
    nature: 'Nature',
    representative: 'Representative',
    position: 'Position',
    street: 'Street',
    city: 'City',
    state: 'State',
    postal_code: '1234',
    country_code: 'PH',
    phone: '+63.21234567',
    fax: '+63.21234567',
    email: 'alpha@alpha.org',
    local: true,
    admin: false
  }
end

def alpha_partner credits: 0.00
  {
    id: 1,
    name: 'alpha',
    organization: 'Company',
    credits: credits,
    site: 'http://alpha.ph',
    nature: 'Alpha Business',
    representative: 'Alpha Guy',
    position: 'Position',
    street: 'Alpha Street',
    city: 'Alpha City',
    state: 'Alpha State',
    postal_code: '1234',
    country_code: 'PH',
    phone: '+63.1234567',
    fax: '+63.1234567',
    email: 'alpha@alpha.ph',
    local: true,
    admin: false
  }
end

def product id: 1, type: 'domain', name: 'domain.ph'
  {
    id: id,
    type: type,
    name: name
  }
end
