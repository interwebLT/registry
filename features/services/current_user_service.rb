def view_current_partner
  get partner_user_index_path
end

def assert_current_partner_info_displayed
  assert_response_status_must_be_ok

  expected_response = {
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
    postal_code: '1234',
    country_code: 'PH',
    phone: '+63.21234567',
    fax: '+63.21234567',
    email: 'alpha@alpha.org',
    local: true,
    admin: false,
    default_nameservers: [
      {
        name: 'ns3.domains.ph'
      },
      {
        name: 'ns4.domains.ph'
      }
    ],
    pricing: [
      {
        id: 1,
        action: 'domain_create',
        period: 1,
        price: 35.00
      },
      {
        id: 2,
        action: 'domain_create',
        period: 2,
        price: 70.00
      },
      {
        id: 3,
        action: 'domain_create',
        period: 3,
        price: 105.00
      },
      {
        id: 4,
        action: 'domain_create',
        period: 4,
        price: 140.00
      },
      {
        id: 5,
        action: 'domain_create',
        period: 5,
        price: 175.00
      },
      {
        id: 6,
        action: 'domain_create',
        period: 6,
        price: 210.00
      },
      {
        id: 7,
        action: 'domain_create',
        period: 7,
        price: 245.00
      },
      {
        id: 8,
        action: 'domain_create',
        period: 8,
        price: 280.00
      },
      {
        id: 9,
        action: 'domain_create',
        period: 9,
        price: 315.00
      },
      {
        id: 10,
        action: 'domain_create',
        period: 10,
        price: 350.00
      }
    ]
  }

  json_response.must_equal expected_response
end
