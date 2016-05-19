When /^I register a domain$/ do
  request = 'orders/post_register_domain_request'

  create :contact

  stub_request(:post, 'http://localhost:9001/orders')
    .with(headers: headers, body: request.body)
    .to_return status: 201

  post orders_path, request.json
end

When /^I register a domain with two-level TLD$/ do
  request = 'orders/post_register_domain_with_two_level_tld_request'

  create :contact

  stub_request(:post, 'http://localhost:9001/orders')
    .with(headers: headers, body: request.body)
    .to_return status: 201

  post orders_path, request.json
end

When /^I register a domain with no domain name$/ do
  post orders_path, 'orders/post_register_domain_with_no_domain_name_request'.json
end

When /^I register a domain with no period$/ do
  post orders_path, 'orders/post_register_domain_with_no_period_request'.json
end

When /^I register a domain with no registrant handle$/ do
  post orders_path, 'orders/post_register_domain_with_no_registrant_handle_request'.json
end

Then /^domain must be registered$/ do
  json_response.must_equal 'orders/post_register_domain_response'.json

  Domain.exists? name: DOMAIN
end

Then /^domain with two-level TLD must be registered$/ do
  json_response.must_equal 'orders/post_register_domain_with_two_level_tld_response'.json

  Domain.exists? name: TWO_LEVEL_DOMAIN
end

Then /^register domain fee must be deducted$/ do
  assert_fee_deducted 70.00.money
end
