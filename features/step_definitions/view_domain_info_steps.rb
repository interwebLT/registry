When /^I try to view the info of a domain that I own$/ do
  domain = FactoryGirl.create :domain, partner: @current_user.partner

  get domain_url(domain.id)
end

Then /^I must see the info of my domain$/ do
  expect(last_response.status).to eq 200

  expect(json_response).to eql 'domains/domain.ph/get_response'.json
end
