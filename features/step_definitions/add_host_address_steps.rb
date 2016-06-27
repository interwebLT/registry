When /^I try to add a host address to an existing host$/ do
  host = FactoryGirl.create :host

  stub_request(:post, 'http://localhost:9001/hosts/ns5.domains.ph/addresses')
    .to_return status: 200, body: 'hosts/ns5.domains.ph/addresses/post_response'.body

  post host_addresses_path(host.name), 'hosts/ns5.domains.ph/addresses/post_request'.json
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
