When /^I try to add a host address to an existing host$/ do
  host = FactoryGirl.create :host

  stub_request(:get, 'http://localhost:9001/hosts/ns5.domains.ph')
    .to_return status: 200, body: 'hosts/ns5.domains.ph/get_response'.body

  stub_request(:post, 'http://localhost:9001/hosts/ns5.domains.ph/addresses')
    .to_return status: 200, body: 'hosts/ns5.domains.ph/addresses/post_response'.body

  post host_addresses_path(host.name), 'hosts/ns5.domains.ph/addresses/post_request'.json
end

When /^I try to add a host address before host exists$/ do
  host = FactoryGirl.create :host

  stub_request(:get, 'http://localhost:9001/hosts/ns5.domains.ph')
    .to_return(status: 404, body: 'common/404'.body).times(9)
    .to_return status: 200, body: 'hosts/ns5.domains.ph/get_response'.body

  stub_request(:post, 'http://localhost:9001/hosts/ns5.domains.ph/addresses')
    .to_return status: 200, body: 'hosts/ns5.domains.ph/addresses/post_response'.body

  post host_addresses_path(host.name), 'hosts/ns5.domains.ph/addresses/post_request'.json
end

When /^I try to add a host address where host does not exist$/ do
  stub_request(:get, 'http://localhost:9001/hosts/ns5.domains.ph')
    .to_return status: 404, body: 'common/404'.body
end

Then /^host must now have host address$/ do
  expect(last_response).to have_attributes status: 201
  expect(json_response).to eql 'hosts/ns5.domains.ph/addresses/post_response'.json

  expect(Host.last.host_addresses.first).to have_attributes address:  '123.123.123.001',
                                                            type:     'v4'
end

Then /^add host address must be synced to external registries$/ do
  expect(WebMock).to have_requested(:post, 'http://localhost:9001/hosts/ns5.domains.ph/addresses')
    .with headers: HEADERS, body: 'hosts/ns5.domains.ph/addresses/post_request'.json
end

Then /^add host address must not be synced to external registries$/ do
  url = 'http://localhost:9001/hosts/ns5.domains.ph/addresses'

  expect(WebMock).not_to have_requested(:post, url)
end

Then /^host must be checked until available$/ do
  expect(WebMock).to have_requested(:get, 'http://localhost:9001/hosts/ns5.domains.ph').times(10)
end

Then /^create host address must reach max retries$/ do
  host = FactoryGirl.build :host

  begin
    post host_addresses_path(host.name), 'hosts/ns5.domains.ph/addresses/post_request'.json

    fail
  rescue Exception => e
    expect(e).to be_an_instance_of RuntimeError
  end
end
