When /^I try to remove a domain host from an existing domain$/ do
  domain      = FactoryGirl.create :domain
  domain_host = FactoryGirl.create :domain_host, product: domain.product

  delete domain_host_path(domain.name, domain_host.name)
end

Then /^domain host must be removed$/ do
  expect(last_response).to have_attributes status: 200

  expect(DomainHost.all).to be_empty
end
