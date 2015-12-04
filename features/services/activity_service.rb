def view_activities
  domain = create :domain
  create :update_domain_activity, product: domain.product

  get activities_path
end

def assert_activities_displayed
  assert_response_status_must_be_ok

	json_response.must_match_json_expression activities_response
end

private

def activities_response
  [
    {
      id: 1,
      type: 'update',
      partner:     {
        id: 1,
        name: /alpha[0-9]*/,
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
      activity_at: '2015-01-01T00:00:00Z',
      object: {
        id: 1,
        type: 'domain',
        name: 'domain.ph'
      },
      property_changed: 'expires_at',
      old_value: '2015-04-15T12:00:00Z',
      new_value: '2017-04-15T12:00:00Z'
    },
    {
      id: 2,
      type: 'create',
      partner:     {
        id: 2,
        name: /alpha[0-9]*/,
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
      activity_at: '2015-01-01T00:00:00Z',
      object: {
        id: 2,
        type: 'domain',
        name: 'domain.ph'
      }
    }
  ]
end
