When /^I renew an existing domain$/ do
  FactoryGirl.create :domain

  stub_request(:post, 'http://localhost:9001/orders')
    .to_return status: 201, body: 'orders/post_renew_domain_response'.body

  post orders_path, 'orders/post_renew_domain_request'.json
end

When /^I renew an existing domain with two-level TLD$/ do
  FactoryGirl.create :domain, name: 'domain.com.ph'

  stub_request(:post, 'http://localhost:9001/orders')
    .to_return status: 201, body: 'orders/post_renew_domain_with_two_level_tld_response'.body

  post orders_path, 'orders/post_renew_domain_with_two_level_tld_request'.json
end

When /^I renew an existing domain which external registries reject$/ do
  FactoryGirl.create :domain

  stub_request(:post, 'http://localhost:9001/orders').to_return status: 422

  begin
    post orders_path, 'orders/post_renew_domain_request'.json
  rescue RuntimeError
    @exception_thrown = true
  end
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
