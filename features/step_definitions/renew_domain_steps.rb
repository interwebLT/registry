When /^I renew an existing domain$/ do
  create :domain, partner: @current_partner

  request = 'order/create_renew_domain_request'

  stub_request(:post, SyncOrderJob::URL)
    .with(headers: headers, body: request.body)
    .to_return status: 201

  post orders_path, request.json
end

Then /^domain must be renewed$/ do
  json_response.must_equal 'order/create_renew_domain_response'.json

  saved_domain.expires_at.must_equal '2017-01-01'.in_time_zone
end

Then /^renew domain fee must be deducted$/ do
  assert_fee_deducted 64.00.money
end
