When /^I renew an existing domain$/ do
  request = 'orders/post_renew_domain_request'

  create :domain, partner: @current_partner

  stub_request(:post, 'http://localhost:9001/orders')
    .with(headers: headers, body: request.body)
    .to_return status: 201

  post orders_path, request.json
end

When /^I renew an existing domain with two-level TLD$/ do
  request = 'orders/post_renew_domain_with_two_level_tld_request'

  create :domain, partner: @current_partner, name: 'domain.com.ph'

  stub_request(:post, 'http://localhost:9001/orders')
    .with(headers: headers, body: request.body)
    .to_return status: 201

  post orders_path, request.json
end

When /^I renew an existing domain which other systems reject$/ do
  request = 'orders/post_renew_domain_request'

  stub_request(:post, 'http://localhost:9001/orders')
    .with(headers: headers, body: request.body)
    .to_return status: 422

  create :domain, partner: @current_partner

  begin
    post orders_path, request.json
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
  json_response.must_equal 'orders/post_renew_domain_response'.json

  Domain.named('domain.ph').expires_at.must_equal '2017-01-01'.in_time_zone
end

Then /^domain with two\-level TLD must be renewed$/ do
  json_response.must_equal 'orders/post_renew_domain_with_two_level_tld_response'.json

  Domain.named('domain.com.ph').expires_at.must_equal '2017-01-01'.in_time_zone
end

Then /^renew domain fee must be deducted$/ do
  assert_fee_deducted 64.00.money
end
