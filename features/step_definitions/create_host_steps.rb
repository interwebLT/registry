When /^I create a host entry$/ do
  post hosts_path, 'hosts/post_request'.json
end

Then /^host entry must be created under my partner$/ do
  expect(last_response).to have_attributes status: 201
  expect(json_response).to eq 'hosts/post_response'.json

  expect(Host.last).to have_attributes  name:     'ns5.domains.ph',
                                        partner:  @current_partner
end
