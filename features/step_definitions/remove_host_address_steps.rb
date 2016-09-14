When /^I try to remove a host address from an existing host$/ do
  host          = FactoryGirl.create :host
  host_address  = FactoryGirl.create :host_address, host: host

  stub_request(:get, 'http://localhost:9001/hosts/ns5.domains.ph')
    .to_return(status: 200, body: 'hosts/ns5.domains.ph/get_response'.body)

  stub_request(:delete, "http://localhost:9001/hosts/ns5.domains.ph/addresses/123.123.123.001")
    .to_return(status: 200, body: 'hosts/ns5.domains.ph/addresses/delete_response'.body)

  delete host_address_path(host.name, host_address.address)
end

Then /^host must no longer have host address$/ do
  expect(last_response).to have_attributes status: 200
  expect(json_response).to eq 'hosts/ns5.domains.ph/addresses/delete_response'.json

  expect(Host.last.host_addresses).to be_empty
end

# Then /^remove host address must not be synced to external registries$/ do
#   url = 'http://localhost:9001/hosts/ns5.domains.ph/addresses/123.123.123.001'

#   expect(WebMock).not_to have_requested(:delete, url)
# end
