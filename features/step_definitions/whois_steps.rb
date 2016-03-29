When /^I try to view the whois info of an existing domain$/ do
  domain = FactoryGirl.create :domain

  get whois_path(domain.name)
end

When /^I try to view the whois info of a non\-existing domain$/ do
  get whois_path('doesnotexist.ph')
end

Then /^I must see the whois info of the domain$/ do
  expect(last_response.status).to eq 200

  expect(json_response).to eq 'whois/domain.ph/get_response'.json
end

Then /^I must be notified that domain does not exist$/ do
  expect(last_response.status).to eq 404
end
