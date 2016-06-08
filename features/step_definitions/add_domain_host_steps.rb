When /^I try to add a domain host to an existing domain$/ do
  domain = FactoryGirl.create :domain

  stub_request(:post, 'http://localhost:9001/domains/domain.ph/hosts')
    .to_return status: 200, body: 'domains/domain.ph/hosts/post_response'.body

  post domain_hosts_path(domain.name), 'domains/domain.ph/hosts/post_request'.json
end

Then /^domain must now have domain host$/ do
  expect(last_response).to have_attributes status: 201
  expect(json_response).to eql 'domains/domain.ph/hosts/post_response'.json

  expect(DomainHost.last).to have_attributes name: 'ns5.domains.ph'
end

Then /^add domain host must be synced to external registries$/ do
  expect(WebMock).to have_requested(:post, 'http://localhost:9001/domains/domain.ph/hosts')
    .with headers: default_headers, body: 'domains/domain.ph/hosts/post_request'.json
end
