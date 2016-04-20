When /^I try to remove a domain host from an existing domain$/ do
  domain      = FactoryGirl.create :domain
  domain_host = FactoryGirl.create :domain_host, product: domain.product

  stub_request(:delete, SyncDeleteDomainHostJob.url(domain.name, domain_host.name))
    .with(headers: headers)
    .to_return status: 200

  delete domain_host_path(domain.name, domain_host.name)
end

Then /^domain host must be removed$/ do
  expect(last_response).to have_attributes status: 200

  expect(DomainHost.all).to be_empty
end

Then /^remove domain host must be synced to other systems$/ do
  expect(WebMock).to have_requested(:delete, url('/domains/domain.ph/hosts/ns5.domains.ph'))
    .with headers: default_headers
end
