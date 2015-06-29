def domain_host_does_not_exist name: HOST_NAME
  saved_domain_host = DomainHost.find_by(name: name)
  saved_domain_host.delete if saved_domain_host
end

def domain_host_exists domain: DOMAIN
  saved_domain = Domain.named(domain)

  create :domain_host, product: saved_domain.product, name: HOST_NAME
end

def add_domain_host name: HOST_NAME
  json_request = {
    name: name
  }

  json_request.delete(:name) if name == NO_HOST_NAME

  post domain_hosts_url(DOMAIN), json_request
end

def remove_domain_host name: HOST_NAME
  delete domain_host_url(DOMAIN, name)
end

def remove_all_domain_hosts
  saved_domain.product.domain_hosts.each do |domain_host|
    delete domain_host_url(DOMAIN, domain_host.name)
    assert_response_status_must_be_ok
  end
end

def assert_response_must_be_created_domain_host
  assert_response_status_must_be_created

  expected_response = {
    id: 1,
    name: 'ns5.domains.ph',
    created_at: '2015-01-01T00:00:00Z',
    updated_at: '2015-01-01T00:00:00Z'
  }

  json_response.must_equal expected_response
end

def assert_domain_host_must_be_created
  saved_domain_host = DomainHost.last

  saved_domain_host.wont_be_nil
  saved_domain_host.name.must_equal HOST_NAME
  saved_domain_host.product.domain.full_name.must_equal DOMAIN
end

def assert_add_domain_host_domain_activity_must_be_created
  saved_domain = Domain.named(DOMAIN)

  saved_domain.domain_activities.count.must_equal 4

  domain_activity = saved_domain.domain_activities[1]
  domain_activity.must_be_instance_of ObjectActivity::Update
  domain_activity.property_changed.must_equal 'domain_host'
  domain_activity.old_value.must_be_nil
  domain_activity.value.must_equal HOST_NAME
end

def assert_response_must_be_deleted_domain_host
  assert_response_status_must_be_ok

  expected_response = {
    id: 1,
    name: 'ns5.domains.ph',
    created_at: '2015-01-01T00:00:00Z',
    updated_at: '2015-01-01T00:00:00Z'
  }

  json_response.must_equal expected_response
end

def assert_domain_host_must_be_deleted
  saved_domain = Domain.named(DOMAIN)

  saved_domain.product.domain_hosts.exists?(name: HOST_NAME)
end

def assert_remove_domain_host_domain_activity_must_be_created
  saved_domain = Domain.named(DOMAIN)

  saved_domain.domain_activities.count.must_equal 7

  domain_activity = saved_domain.domain_activities[4]
  domain_activity.must_be_instance_of ObjectActivity::Update
  domain_activity.property_changed.must_equal 'domain_host'
  domain_activity.old_value.must_equal HOST_NAME
  domain_activity.value.must_be_nil
end

def assert_domain_status_must_not_be_client_hold
  saved_domain = Domain.named(DOMAIN)

  saved_domain.client_hold.must_equal false
end
