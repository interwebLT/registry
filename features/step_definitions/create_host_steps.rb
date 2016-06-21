When /^I create a host entry$/ do
  post hosts_path, 'hosts/post_request'.json
end

When /^I create a host entry with no host name$/ do
  post hosts_path, 'hosts/post_with_no_host_name_request'.json
end

When /^I create a host entry with existing host name$/ do
  FactoryGirl.create :host

  post hosts_path, 'hosts/post_with_existing_host_name_request'.json
end

Then /^host entry must be created under my partner$/ do
  expect(last_response).to have_attributes status: 201
  expect(json_response).to eq 'hosts/post_response'.json

  expect(Host.last).to have_attributes  name:     'ns5.domains.ph',
                                        partner:  @current_partner
end
