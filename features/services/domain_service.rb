DOMAIN = 'domain.ph'
OTHER_DOMAIN = 'other_domain.ph'
AUTHCODE = 'ABC123'

def saved_domain name: DOMAIN
  Domain.named(name)
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
  'set server hold'                     =>  { server_hold: true },
  'set server delete prohibited'        =>  { server_delete_prohibited: true },
  'set server renew prohibited'         =>  { server_renew_prohibited: true },
  'set server transfer prohibited'      =>  { server_transfer_prohibited: true },
  'set server update prohibited'        =>  { server_update_prohibited: true },
  'unset server hold'                   =>  { server_hold: false },
  'unset server delete prohibited'      =>  { server_delete_prohibited: false },
  'unset server renew prohibited'       =>  { server_renew_prohibited: false },
  'unset server transfer prohibited'    =>  { server_transfer_prohibited: false },
  'unset server update prohibited'      =>  { server_update_prohibited: false },
  'invalid server hold'                 =>  { server_hold: 'invalid' },
  'invalid server delete prohibited'    =>  { server_delete_prohibited: 'invalid' },
  'invalid server renew prohibited'     =>  { server_renew_prohibited: 'invalid' },
  'invalid server transfer prohibited'  =>  { server_transfer_prohibited: 'invalid' },
  'invalid server update prohibited'    =>  { server_update_prohibited: 'invalid' },
  'nil server hold'                     =>  { server_hold: nil },
  'nil server delete prohibited'        =>  { server_delete_prohibited: nil },
  'nil server renew prohibited'         =>  { server_renew_prohibited: nil },
  'nil server transfer prohibited'      =>  { server_transfer_prohibited: nil },
  'nil server update prohibited'        =>  { server_update_prohibited: nil },
  'blank server hold'                   =>  { server_hold: '' },
  'blank server delete prohibited'      =>  { server_delete_prohibited: '' },
  'blank server renew prohibited'       =>  { server_renew_prohibited: '' },
  'blank server transfer prohibited'    =>  { server_transfer_prohibited: '' },
  'blank server update prohibited'      =>  { server_update_prohibited: '' },
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

def domain_changes_not_allowed status:
  status_field = status.gsub(' ', '_')

  saved_domain.update(status_field.to_sym => true)
end

def view_domains
  get domains_path
end

def search_domains search_term
  get domains_path(search: search_term)
end

def search_second_level_domains search_term
  get "/availability?domain=#{search_term}"
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

  json_response.must_match_json_expression domain_response.merge(params)
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
  saved_domain.ok.must_equal true
  saved_domain.inactive.must_equal false
  saved_domain.client_hold.must_equal false
  saved_domain.client_delete_prohibited.must_equal false
  saved_domain.client_renew_prohibited.must_equal false
  saved_domain.client_transfer_prohibited.must_equal false
  saved_domain.client_update_prohibited.must_equal false
end

def assert_domain_status_must_be_inactive
  saved_domain.ok.must_equal false
  saved_domain.inactive.must_equal true
  saved_domain.client_hold.must_equal false
  saved_domain.client_delete_prohibited.must_equal false
  saved_domain.client_renew_prohibited.must_equal false
  saved_domain.client_transfer_prohibited.must_equal false
  saved_domain.client_update_prohibited.must_equal false
end

def assert_domain_must_not_have_hosts
  saved_domain.product.domain_hosts.must_be_empty
end

def assert_domain_status_response status:, action:
  status_field = status.gsub(' ', '_')
  action_flag = true if action == 'set'
  action_flag = false if action == 'unset'

  assert_response_must_be_updated_domain with: { status_field.to_sym => action_flag }

  saved_domain.send(status_field).must_equal action_flag
end

def assert_domains_displayed
  assert_response_status_must_be_ok

	json_response.must_match_json_expression [domain_response]
end

def assert_latest_domains_displayed
  assert_response_status_must_be_ok

  expected_response = [
    domain_response(id: 1, name: 'jkl.ph', registered_at: '2015-03-15T14:03:00Z'),
    domain_response(id: 2, name: 'ghi.ph', registered_at: '2015-03-15T14:02:00Z'),
    domain_response(id: 3, name: 'def.ph', registered_at: '2015-03-15T14:01:00Z'),
    domain_response(id: 4, name: 'abc.ph', registered_at: '2015-03-15T14:00:00Z')
  ]


  json_response.must_match_json_expression expected_response
end

def assert_domains_count_must_be count
  assert_response_status_must_be_ok
  json_response.length.must_equal count
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
    partner: /alpha[0-9]*/,
    registered_at: registered_at,
    expires_at: '2015-01-01T00:00:00Z',
    registrant_handle: registrant,
    admin_handle: nil,
    billing_handle: nil,
    tech_handle: nil,
    inactive: true,
    client_hold: false,
    client_delete_prohibited: false,
    client_renew_prohibited: false,
    client_transfer_prohibited: false,
    client_update_prohibited: false,
    server_hold: false,
    server_delete_prohibited: false,
    server_renew_prohibited: false,
    server_transfer_prohibited: false,
    server_update_prohibited: false,
    expired: true,
    expiring: false
  }
end
