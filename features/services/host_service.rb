HOST_NAME = 'ns5.domains.ph'
OTHER_HOST_NAME = 'ns6.domains.ph'
DEFAULT_HOST_NAME = 'ns3.domains.ph'
DEFAULT_HOST_NAME2 = 'ns4.domains.ph'

NO_HOST_NAME = 'NO_HOST_NAME'

BLANK_HOST_NAME = ''

def saved_host name: HOST_NAME
  return Host.find_by name: name
end

def host_does_not_exist name: HOST_NAME
  saved_host = Host.find_by(name: name)
  saved_host.delete if saved_host
end

def host_exists name: HOST_NAME
  host_does_not_exist name: name

  create :host, name: name
end

def host_with_addresses_exists name: HOST_NAME
  host_does_not_exist name: name

  create :host_with_addresses, name: name
end

def create_host partner: NON_ADMIN_PARTNER, name: HOST_NAME
  json_request = {
    partner: partner,
    name: name
  }

  json_request.delete(:partner) if partner == NO_PARTNER
  json_request.delete(:name) if name == NO_HOST_NAME

  post hosts_url, json_request
end

def view_hosts
  get hosts_path
end

def view_host_info
  get host_path(saved_host.id)
end

def assert_response_must_be_created_host
  assert_response_status_must_be_created

  expected_response = {
    id: 1,
    partner: NON_ADMIN_PARTNER,
    name: HOST_NAME,
    host_addresses: [],
    created_at: '2015-01-01T00:00:00Z',
    updated_at: '2015-01-01T00:00:00Z'
  }

  json_response.must_equal expected_response
end

def assert_host_must_be_created
  host = Host.last

  host.partner.name.must_equal NON_ADMIN_PARTNER
  host.name.must_equal HOST_NAME
end

def assert_hosts_displayed
  assert_response_status_must_be_ok

  json_response.length.must_equal 3
  json_response.must_match_json_expression hosts_response
end

def assert_host_info_displayed
  assert_response_status_must_be_ok

  json_response.must_match_json_expression host_info_response
end

def assert_no_hosts_displayed
  assert_response_status_must_be_ok

  json_response.length.must_equal 0
end

def assert_no_host_displayed
  assert_response_status_must_be_ok

  json_response.must_equal []
end

def host_info_response
  {:id=>1, :partner=>/alpha[0-9]*/, :name=>"ns5.domains.ph", :host_addresses=>[
    {:address=>"123.456.789.001", :type=>"v4"}, 
    {:address=>"123.456.789.002", :type=>"v4"}
  ], :created_at=>"2015-01-01T00:00:00Z", :updated_at=>"2015-01-01T00:00:00Z"}
end

def hosts_response
[{:id=>1, :partner=>"admin", :name=>"ns3.domains.ph", :host_addresses=>[], :created_at=>"2015-01-01T00:00:00Z", :updated_at=>"2015-01-01T00:00:00Z"}, 
{:id=>2, :partner=>"admin", :name=>"ns4.domains.ph", :host_addresses=>[], :created_at=>"2015-01-01T00:00:00Z", :updated_at=>"2015-01-01T00:00:00Z"}, 
{:id=>3, :partner=>/alpha[0-9]*/, :name=>"ns5.domains.ph", :host_addresses=>[
    {:address=>"123.456.789.001", :type=>"v4"}, 
    {:address=>"123.456.789.002", :type=>"v4"}
  ], :created_at=>"2015-01-01T00:00:00Z", :updated_at=>"2015-01-01T00:00:00Z"}]
end
