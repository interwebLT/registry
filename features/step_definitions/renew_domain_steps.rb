RENEW_DOMAIN = Transform /^renew an existing domain(?: |)(.*?)$/ do |scenario|
  build_request scenario: scenario, resource: :order, action: :post_renew_domain
end

When /^I (#{RENEW_DOMAIN})$/ do |request|
  registrant = create :contact

  create :domain, partner: @current_partner, registrant: registrant
  create :domain, partner: @current_partner, registrant: registrant, name: 'domain.com.ph'

  stub_request(:post, SyncOrderJob::URL)
    .with(headers: headers, body: request.body)
    .to_return status: 201

  post orders_path, request.json
end

When /^I renew an existing domain which other systems reject$/ do
  request = 'order/post_renew_domain_request'

  stub_request(:post, SyncOrderJob::URL)
    .with(headers: headers, body: request.body)
    .to_return status: 422

  create :domain, partner: @current_partner

  begin
    post orders_path, request.json
  rescue RuntimeError
    @exception_thrown = true
  end
end

Then /^domain must be renewed$/ do
  json_response.must_equal 'order/post_renew_domain_response'.json

  Domain.named('domain.ph').expires_at.must_equal '2017-01-01'.in_time_zone
end

Then /^domain with two\-level TLD must be renewed$/ do
  json_response.must_equal 'order/post_renew_domain_with_two_level_tld_response'.json

  Domain.named('domain.com.ph').expires_at.must_equal '2017-01-01'.in_time_zone
end

Then /^renew domain fee must be deducted$/ do
  assert_fee_deducted 64.00.money
end
