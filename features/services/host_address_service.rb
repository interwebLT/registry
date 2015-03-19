HOST_ADDRESS = '123.456.789.001'
HOST_ADDRESS_TYPE = 'v4'

BLANK_HOST_ADDRESS = ''
BLANK_HOST_ADDRESS_TYPE = ''

INVALID_HOST_ADDRESS_TYPE = 'v5'

NO_HOST_ADDRESS = nil
NO_HOST_ADDRESS_TYPE = nil

def host_address_does_not_exist address: HOST_ADDRESS
  saved_host_address = HostAddress.find_by(address: address)
  saved_host_address.delete if saved_host_address
end

def host_address_exists host: HOST_NAME
  saved_host = Host.find_by(name: host)

  create :host_address, host: saved_host, address: HOST_ADDRESS
end

def add_host_address address: HOST_ADDRESS, type: HOST_ADDRESS_TYPE
  json_request = {
    address: address,
    type: type
  }

  json_request.delete(:address) unless address
  json_request.delete(:type) unless type

  post host_addresses_url(HOST_NAME), json_request
end

def remove_host_address address: HOST_ADDRESS
  delete host_address_url(HOST_NAME, address)
end

def assert_response_must_be_created_host_address
  assert_response_status_must_be_created

  expected_response = {
    id: 1,
    address: '123.456.789.001',
    type: 'v4',
    created_at: '2015-01-01T00:00:00Z',
    updated_at: '2015-01-01T00:00:00Z',
  }

  json_response.must_equal expected_response
end

def assert_host_address_must_be_created
  saved_host_address = HostAddress.last

  saved_host_address.address.must_equal '123.456.789.001'
  saved_host_address.type.must_equal 'v4'
end

def assert_host_address_removed
  assert_response_status_must_be_ok

  expected_response = {
    id: 1,
    address: '123.456.789.001',
    type: 'v4',
    created_at: '2015-01-01T00:00:00Z',
    updated_at: '2015-01-01T00:00:00Z',
  }

  json_response.must_equal expected_response

  HostAddress.exists?(address: HOST_ADDRESS).wont_equal true
end
