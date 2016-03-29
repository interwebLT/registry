When /^I try to view the info of an existing domain that I own$/ do
  domain = FactoryGirl.create :domain, partner: @current_user.partner

  get domain_url(domain.id)
end

When /^I try to view the info an existing domain owned by another partner$/ do
  domain  = FactoryGirl.create :domain
  domain.update partner: FactoryGirl.create(:other_partner)

  get domain_url(domain.id)
end

When /^I try to view the info of an existing domain that I own via domain name$/ do
  domain = FactoryGirl.create :domain, partner: @current_user.partner

  get domain_url(domain.name)
end

When /^I try to view the info of a domain that does not exist$/ do
  get domain_url('doesnotexist.ph')
end

Then /^I must see the info of my domain$/ do
  expect(last_response.status).to eq 200

  expect(json_response).to eql 'domains/domain.ph/get_response'.json
end

Then /^I must not be able to see the domain$/ do
  expect(last_response.status).to eq 404
end
