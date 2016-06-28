When /^I try to add a domain host to an existing domain$/ do
  domain = FactoryGirl.create :domain

  stub_request(:get, 'http://localhost:9001/domains/domain.ph')
    .to_return status: 200, body: 'domains/domain.ph/get_response'.body

  stub_request(:post, 'http://localhost:9001/domains/domain.ph/hosts')
    .to_return status: 200, body: 'domains/domain.ph/hosts/post_response'.body

  post domain_hosts_path(domain.name), 'domains/domain.ph/hosts/post_request'.json
end

When /^I try to add a domain host before domain is registered$/ do
  domain = FactoryGirl.create :domain

  stub_request(:get, 'http://localhost:9001/domains/domain.ph')
    .to_return(status: 404, body: 'common/404'.body).times(9)
    .to_return status: 200, body: 'domains/domain.ph/get_response'.body

  stub_request(:post, 'http://localhost:9001/domains/domain.ph/hosts')
    .to_return status: 200, body: 'domains/domain.ph/hosts/post_response'.body

  post domain_hosts_path(domain.name), 'domains/domain.ph/hosts/post_request'.json
end

When /^I try to add a domain host where domain does not exist$/ do
  domain = FactoryGirl.create :domain

  stub_request(:get, 'http://localhost:9001/domains/domain.ph')
    .to_return(status: 404, body: 'common/404'.body)
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

Then /^add domain host must reach max retries$/ do
  begin
    post domain_hosts_path(Domain.last.name), 'domains/domain.ph/hosts/post_request'.json

    fail
  rescue Exception => e
    expect(e).to be_an_instance_of RuntimeError
  end
end
