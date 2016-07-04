When /^I renew an existing domain$/ do
  FactoryGirl.create :domain

  stub_request(:get, 'http://localhost:9001/domains/domain.ph')
    .to_return status: 200, body: 'domains/domain.ph/get_response'.body

  stub_request(:post, 'http://localhost:9001/orders')
    .to_return status: 201, body: 'orders/post_renew_domain_response'.body

  post orders_path, 'orders/post_renew_domain_request'.json
end

When /^I renew an existing domain with two-level TLD$/ do
  FactoryGirl.create :domain, name: 'domain.com.ph'

  stub_request(:get, 'http://localhost:9001/domains/domain.com.ph')
    .to_return status: 200, body: 'domains/domain.ph/get_response'.body

  stub_request(:post, 'http://localhost:9001/orders')
    .to_return status: 201, body: 'orders/post_renew_domain_with_two_level_tld_response'.body

  post orders_path, 'orders/post_renew_domain_with_two_level_tld_request'.json
end

When /^I renew a domain before it is registered$/ do
  FactoryGirl.create :domain

  stub_request(:get, 'http://localhost:9001/domains/domain.ph')
    .to_return(status: 404, body: 'common/404'.body).times(9)
    .to_return status: 200, body: 'domains/domain.ph/get_response'.body

  stub_request(:post, 'http://localhost:9001/orders')
    .to_return status: 201, body: 'orders/post_renew_domain_response'.body

  post orders_path, 'orders/post_renew_domain_request'.json
end

When /^I renew a domain where domain does not exist$/ do
  FactoryGirl.create :domain

  stub_request(:get, 'http://localhost:9001/domains/domain.ph')
    .to_return(status: 404, body: 'common/404'.body)
end

When /^I renew an existing domain with no domain name$/ do
  post orders_path, 'orders/post_renew_domain_with_no_domain_name_request'.json
end

When /^I renew an existing domain with no period$/ do
  post orders_path, 'orders/post_renew_domain_with_no_period_request'.json
end

Then /^domain must be renewed$/ do
  expect(last_response.status).to eq 201
  expect(json_response).to eq 'orders/post_renew_domain_response'.json

  expect(Domain.last).to have_attributes expires_at: '2017-01-01'.in_time_zone
end

Then /^domain with two\-level TLD must be renewed$/ do
  expect(last_response.status).to eq 201
  expect(json_response).to eq 'orders/post_renew_domain_with_two_level_tld_response'.json

  expect(Domain.last).to have_attributes expires_at: '2017-01-01'.in_time_zone
end

Then /^renew domain must be synced to external registries$/ do
  expect(WebMock).to have_requested(:post, 'http://localhost:9001/orders')
    .with headers: HEADERS, body: 'orders/post_renew_domain_request'.json
end

Then /^renew domain must not be synced to external registries$/ do
  expect(WebMock).not_to have_requested(:post, 'http://localhost:9001/orders')
end

Then /^renew domain fee must be deducted$/ do
  assert_fee_deducted 64.00.money
end

Then /^domain must be checked until registered$/ do
  expect(WebMock).to have_requested(:get, 'http://localhost:9001/domains/domain.ph').times(10)
end

Then /^renew domain must reach max retries$/ do
  begin
    post orders_path, 'orders/post_renew_domain_request'.json

    fail
  rescue Exception => e
    expect(e).to be_an_instance_of RuntimeError
    expect(e).to have_attributes message: 'Max retry reached!'
  end
end
