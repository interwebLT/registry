When /^I try to add a domain host to an existing domain$/ do
  request = 'domains/domain.ph/hosts/post_request'

  domain = FactoryGirl.create :domain

  stub_request(:post, 'http://localhost:9001/domains/domain.ph/hosts')
    .with(headers: headers, body: request.body)
    .to_return status: 200

  post domain_hosts_path(domain.name), request.json
end

Then /^domain must now have domain host$/ do
  expect(json_response).to eql 'domains/domain.ph/hosts/post_response'.json

  expect(DomainHost.last).to have_attributes name: 'ns5.domains.ph'
end

Then /^add domain host must be synced to other systems$/ do
  url     = 'http://localhost:9001/domains/domain.ph/hosts'
  request = 'domains/domain.ph/hosts/post_request'

  expect(WebMock).to have_requested(:post, url)
    .with headers: default_headers, body: request.json
end
