DOMAIN = 'domain.ph'
OTHER_DOMAIN = 'other_domain.ph'
AUTHCODE = 'ABC123'

def saved_domain name: DOMAIN
  Domain.named(name)
end

def object_status
  saved_domain.product.object_status
end

def domain_does_not_exist domain: DOMAIN
  saved_domain = Domain.named(domain)
  saved_domain.delete if saved_domain

  contact_does_not_exist
end

def domain_exists domain: DOMAIN, factory: :domain, partner: nil
  domain_does_not_exist domain: domain

  current_partner = partner ? Partner.find_by(name: partner) : @current_partner

  create factory, partner: current_partner, name: domain
end

def domain_with_complete_contacts_exists domain: DOMAIN
  domain_exists domain: domain, factory: :complete_domain
end

def update_domain_contact registrant_handle: NO_UPDATE,
                          admin_handle: NO_UPDATE,
                          billing_handle: NO_UPDATE,
                          tech_handle: NO_UPDATE
  json_request = {
    registrant_handle: registrant_handle,
    admin_handle: admin_handle,
    billing_handle: billing_handle,
    tech_handle: tech_handle
  }

  json_request.delete(:registrant_handle) if registrant_handle == NO_UPDATE
  json_request.delete(:admin_handle)      if admin_handle == NO_UPDATE
  json_request.delete(:billing_handle)    if billing_handle == NO_UPDATE
  json_request.delete(:tech_handle)       if tech_handle == NO_UPDATE

  patch domain_path(DOMAIN), json_request
end

UPDATE_DOMAIN_PARAMS = {
  'set client hold'                     =>  { client_hold: true },
  'set client delete prohibited'        =>  { client_delete_prohibited: true },
  'set client renew prohibited'         =>  { client_renew_prohibited: true },
  'set client transfer prohibited'      =>  { client_transfer_prohibited: true },
  'set client update prohibited'        =>  { client_update_prohibited: true },
  'unset client hold'                   =>  { client_hold: false },
  'unset client delete prohibited'      =>  { client_delete_prohibited: false },
  'unset client renew prohibited'       =>  { client_renew_prohibited: false },
  'unset client transfer prohibited'    =>  { client_transfer_prohibited: false },
  'unset client update prohibited'      =>  { client_update_prohibited: false },
  'invalid client hold'                 =>  { client_hold: 'invalid' },
  'invalid client delete prohibited'    =>  { client_delete_prohibited: 'invalid' },
  'invalid client renew prohibited'     =>  { client_renew_prohibited: 'invalid' },
  'invalid client transfer prohibited'  =>  { client_transfer_prohibited: 'invalid' },
  'invalid client update prohibited'    =>  { client_update_prohibited: 'invalid' },
  'nil client hold'                     =>  { client_hold: nil },
  'nil client delete prohibited'        =>  { client_delete_prohibited: nil },
  'nil client renew prohibited'         =>  { client_renew_prohibited: nil },
  'nil client transfer prohibited'      =>  { client_transfer_prohibited: nil },
  'nil client update prohibited'        =>  { client_update_prohibited: nil },
  'blank client hold'                   =>  { client_hold: '' },
  'blank client delete prohibited'      =>  { client_delete_prohibited: '' },
  'blank client renew prohibited'       =>  { client_renew_prohibited: '' },
  'blank client transfer prohibited'    =>  { client_transfer_prohibited: '' },
  'blank client update prohibited'      =>  { client_update_prohibited: '' },
  'enable client hold but with invalid admin_handle'  => { admin_handle: 'dne', client_hold: true },
  'blank registrant handle'             =>  { registrant_handle: BLANK_CONTACT_HANDLE },
  'non-existing registrant handle'      =>  { registrant_handle: NON_EXISTING_CONTACT_HANDLE },
  'non-existing admin handle'           =>  { admin_handle: NON_EXISTING_CONTACT_HANDLE },
  'non-existing billing handle'         =>  { billing_handle: NON_EXISTING_CONTACT_HANDLE },
  'non-existing tech handle'            =>  { tech_handle: NON_EXISTING_CONTACT_HANDLE },
}

def update_domain with: {}, scenario: nil
  json_request = with
  json_request = UPDATE_DOMAIN_PARAMS[scenario] if scenario

  patch domain_path(DOMAIN), json_request
end

def domain_changes_not_allowed status: status
  status_field = status.gsub(' ', '_')

  object_status.update(status_field.to_sym => true)
end

def view_domain_info
  get domain_path(saved_domain.id)
end

def view_domains
  get domains_path
end

def view_latest_domains
  contact = create :contact

  create :domain, registered_at: '2015-03-15 14:00'.in_time_zone, registrant: contact, name: 'abc.ph'
  create :domain, registered_at: '2015-03-15 14:01'.in_time_zone, registrant: contact, name: 'def.ph'
  create :domain, registered_at: '2015-03-15 14:02'.in_time_zone, registrant: contact, name: 'ghi.ph'
  create :domain, registered_at: '2015-03-15 14:03'.in_time_zone, registrant: contact, name: 'jkl.ph'

  get domains_path
end

def assert_response_must_be_updated_domain(with:)
  params = with

  assert_response_status_must_be_ok

  json_response.must_equal domain_response.merge(params)
end

def assert_domain_must_be_registered domain: DOMAIN
  saved_domain = Domain.named(domain)
  saved_domain.wont_equal nil
  saved_domain.registered_at.must_equal REGISTERED_AT.utc
end

def assert_register_domain_activity_must_be_created
  saved_domain.domain_activities.count.must_equal 1
end

def assert_domain_status_must_be_ok
  object_status.ok.must_equal true
  object_status.inactive.must_equal false
  object_status.client_hold.must_equal false
  object_status.client_delete_prohibited.must_equal false
  object_status.client_renew_prohibited.must_equal false
  object_status.client_transfer_prohibited.must_equal false
  object_status.client_update_prohibited.must_equal false
end

def assert_domain_status_must_be_inactive
  object_status.ok.must_equal false
  object_status.inactive.must_equal true
  object_status.client_hold.must_equal false
  object_status.client_delete_prohibited.must_equal false
  object_status.client_renew_prohibited.must_equal false
  object_status.client_transfer_prohibited.must_equal false
  object_status.client_update_prohibited.must_equal false

  object_status.object_status_histories.last.inactive.must_equal true
end

def assert_domain_must_not_have_hosts
  saved_domain.product.domain_hosts.must_be_empty
end

def assert_domain_status_response status:, action:
  status_field = status.gsub(' ', '_')
  action_flag = true if action == 'set'
  action_flag = false if action == 'unset'

  assert_response_must_be_updated_domain with: { status_field.to_sym => action_flag }

  object_status.send(status_field).must_equal action_flag
end

def assert_domain_info_displayed
  assert_response_status_must_be_ok

  json_response.must_equal domain_info_response
end

def assert_domain_with_complete_contacts_displayed
  assert_response_status_must_be_ok

  json_response.must_equal domain_with_complete_contacts_response
end

def assert_domains_displayed
  assert_response_status_must_be_ok

  json_response.must_equal [domain_response]
end

def assert_latest_domains_displayed
  assert_response_status_must_be_ok

  expected_response = [
    domain_response(id: 1, name: 'jkl.ph', registered_at: '2015-03-15T14:03:00Z'),
    domain_response(id: 2, name: 'ghi.ph', registered_at: '2015-03-15T14:02:00Z'),
    domain_response(id: 3, name: 'def.ph', registered_at: '2015-03-15T14:01:00Z'),
    domain_response(id: 4, name: 'abc.ph', registered_at: '2015-03-15T14:00:00Z')
  ]


  json_response.must_equal expected_response
end

private

def domain_response id: 1,
                    name: DOMAIN,
                    registrant: CONTACT_HANDLE,
                    registered_at: '2014-01-01T00:00:00Z'
  {
    id: id,
    zone: 'ph',
    name: name,
    partner: 'alpha',
    registered_at: registered_at,
    expires_at: '2015-01-01T00:00:00Z',
    registrant: {
      handle: 'contact',
      name: nil,
      organization: nil,
      street: nil,
      street2: nil,
      street3: nil,
      city: nil,
      state: nil,
      postal_code: nil,
      country_code: nil,
      local_name: nil,
      local_organization: nil,
      local_street: nil,
      local_street2: nil,
      local_street3: nil,
      local_city: nil,
      local_state: nil,
      local_postal_code: nil,
      local_country_code: nil,
      voice: nil,
      voice_ext: nil,
      fax: nil,
      fax_ext: nil,
      email: nil
    },
    registrant_handle: registrant,
    admin_handle: nil,
    billing_handle: nil,
    tech_handle: nil,
    client_hold: false,
    client_delete_prohibited: false,
    client_renew_prohibited: false,
    client_transfer_prohibited: false,
    client_update_prohibited: false,
    expired: true,
    expiring: false
  }
end

def domain_info_response
  {
    id: 1,
    zone: 'ph',
    name: 'domain.ph',
    partner: 'alpha',
    registered_at: '2014-01-01T00:00:00Z',
    expires_at: '2015-01-01T00:00:00Z',
    registrant_handle: 'contact',
    registrant: {
      handle: 'contact',
      name: nil,
      organization: nil,
      street: nil,
      street2: nil,
      street3: nil,
      city: nil,
      state: nil,
      postal_code: nil,
      country_code: nil,
      local_name: nil,
      local_organization: nil,
      local_street: nil,
      local_street2: nil,
      local_street3: nil,
      local_city: nil,
      local_state: nil,
      local_postal_code: nil,
      local_country_code: nil,
      voice: nil,
      voice_ext: nil,
      fax: nil,
      fax_ext: nil,
      email: nil
    },
    admin_handle: nil,
    billing_handle: nil,
    tech_handle: nil,
    client_hold: false,
    client_delete_prohibited: false,
    client_renew_prohibited: false,
    client_transfer_prohibited: false,
    client_update_prohibited: false,
    expired: true,
    expiring: false,
    admin_contact: nil,
    billing_contact: nil,
    tech_contact: nil,
    activities: [
      {
        id: 1,
        type: 'create',
        activity_at: '2015-01-01T00:00:00Z',
        object: {
          id: 1,
          type: 'domain',
          name: 'domain.ph'
        }
      }
    ],
    hosts: []
  }
end
def domain_with_complete_contacts_response
  {
    id: 1,
    zone: 'ph',
    name: 'domain.ph',
    partner: 'alpha',
    registered_at: '2014-01-01T00:00:00Z',
    expires_at: '2015-01-01T00:00:00Z',
    registrant_handle: 'contact',
    registrant: {
      handle: 'contact',
      name: nil,
      organization: nil,
      street: nil,
      street2: nil,
      street3: nil,
      city: nil,
      state: nil,
      postal_code: nil,
      country_code: nil,
      local_name: nil,
      local_organization: nil,
      local_street: nil,
      local_street2: nil,
      local_street3: nil,
      local_city: nil,
      local_state: nil,
      local_postal_code: nil,
      local_country_code: nil,
      voice: nil,
      voice_ext: nil,
      fax: nil,
      fax_ext: nil,
      email: nil
    },
    admin_handle: 'contact',
    admin_contact: {
      handle: 'contact',
      name: nil,
      organization: nil,
      street: nil,
      street2: nil,
      street3: nil,
      city: nil,
      state: nil,
      postal_code: nil,
      country_code: nil,
      local_name: nil,
      local_organization: nil,
      local_street: nil,
      local_street2: nil,
      local_street3: nil,
      local_city: nil,
      local_state: nil,
      local_postal_code: nil,
      local_country_code: nil,
      voice: nil,
      voice_ext: nil,
      fax: nil,
      fax_ext: nil,
      email: nil
    },
    billing_handle: 'contact',
    billing_contact: {
      handle: 'contact',
      name: nil,
      organization: nil,
      street: nil,
      street2: nil,
      street3: nil,
      city: nil,
      state: nil,
      postal_code: nil,
      country_code: nil,
      local_name: nil,
      local_organization: nil,
      local_street: nil,
      local_street2: nil,
      local_street3: nil,
      local_city: nil,
      local_state: nil,
      local_postal_code: nil,
      local_country_code: nil,
      voice: nil,
      voice_ext: nil,
      fax: nil,
      fax_ext: nil,
      email: nil
    },
    tech_handle: 'contact',
    tech_contact: {
      handle: 'contact',
      name: nil,
      organization: nil,
      street: nil,
      street2: nil,
      street3: nil,
      city: nil,
      state: nil,
      postal_code: nil,
      country_code: nil,
      local_name: nil,
      local_organization: nil,
      local_street: nil,
      local_street2: nil,
      local_street3: nil,
      local_city: nil,
      local_state: nil,
      local_postal_code: nil,
      local_country_code: nil,
      voice: nil,
      voice_ext: nil,
      fax: nil,
      fax_ext: nil,
      email: nil
    },
    client_hold: false,
    client_delete_prohibited: false,
    client_renew_prohibited: false,
    client_transfer_prohibited: false,
    client_update_prohibited: false,
    expired: true,
    expiring: false,
    activities: [
      {
        id: 1,
        type: 'create',
        activity_at: '2015-01-01T00:00:00Z',
        object: {
          id: 1,
          type: 'domain',
          name: 'domain.ph'
        }
      },
      {
        id: 2,
        type: 'update',
        activity_at: '2015-01-01T00:00:00Z',
        object: {
          id: 2,
          type: 'domain',
          name: 'domain.ph'
        },
        property_changed: 'admin_handle',
        old_value: '',
        new_value: 'contact'
      },
      {
        id: 3,
        type: 'update',
        activity_at: '2015-01-01T00:00:00Z',
        object: {
          id: 3,
          type: 'domain',
          name: 'domain.ph'
        },
        property_changed: 'billing_handle',
        old_value: '',
        new_value: 'contact'
      },
      {
        id: 4,
        type: 'update',
        activity_at: '2015-01-01T00:00:00Z',
        object: {
          id: 4,
          type: 'domain',
          name: 'domain.ph'
        },
        property_changed: 'tech_handle',
        old_value: '',
        new_value: 'contact'
      }
    ],
    hosts: []
  }
end
