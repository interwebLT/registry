When /^I try to remove a domain host from an existing domain$/ do
  domain      = FactoryGirl.create :domain
  domain_host = FactoryGirl.create :domain_host, product: domain.product

  stub_request(:get, 'http://localhost:9001/domains/domain.ph')
    .to_return status: 200, body: 'domains/domain.ph/get_response'.body

  stub_request(:delete, 'http://localhost:9001/domains/domain.ph/hosts/ns5.domains.ph')
    .to_return status: 200, body: 'domains/domain.ph/hosts/ns5.domains.ph/get_response'.body

  delete domain_host_path(domain.name, domain_host.name)
end

When /^I try to remove a domain host before domain is registered$/ do
  domain      = FactoryGirl.create :domain
  domain_host = FactoryGirl.create :domain_host, product: domain.product

  stub_request(:get, 'http://localhost:9001/domains/domain.ph')
    .to_return(status: 404, body: 'common/404'.body).times(9)
    .to_return status: 200, body: 'domains/domain.ph/get_response'.body

  stub_request(:delete, 'http://localhost:9001/domains/domain.ph/hosts/ns5.domains.ph')
    .to_return status: 200, body: 'domains/domain.ph/hosts/ns5.domains.ph/get_response'.body

  delete domain_host_path(domain.name, domain_host.name)
end

Then /^domain host must be removed$/ do
  expect(last_response).to have_attributes status: 200
  expect(json_response).to eq 'domains/domain.ph/hosts/ns5.domains.ph/get_response'.json

  expect(DomainHost.all).to be_empty
end

Then /^remove domain host must be synced to external registries$/ do
  url = 'http://localhost:9001/domains/domain.ph/hosts/ns5.domains.ph'

  expect(WebMock).to have_requested(:delete, url).with headers: default_headers
end

Then /^remove domain host must not be synced to external registries$/ do
  url = 'http://localhost:9001/domains/domain.ph/hosts/ns5.domains.ph'

  expect(WebMock).not_to have_requested(:delete, url)
end
