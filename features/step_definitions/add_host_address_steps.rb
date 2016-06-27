When /^I try to add a host address to an existing host$/ do
  host = FactoryGirl.create :host

  post host_addresses_path(host.name), 'hosts/ns5.domains.ph/addresses/post_request'.json
end

Then /^host must now have host address$/ do
  expect(last_response).to have_attributes status: 201
  expect(json_response).to eql 'hosts/ns5.domains.ph/addresses/post_response'.json

  expect(Host.last.host_addresses.first).to have_attributes address:  '123.123.123.001',
                                                            type:     'v4'
end
