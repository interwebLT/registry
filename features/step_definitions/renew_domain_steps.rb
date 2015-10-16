Given /^I have registered a domain$/ do
  stub_request(:post, SyncOrderJob::URL).to_return(status: 201)

  domain_does_not_exist
  contact_exists
  register_domain
end

When /^I renew my domain$/ do
  stub_request(:post, SyncOrderJob::URL).to_return(status: 201)

  renew_domain
end

When /^I (?:renew|renewed) an existing domain$/ do
  stub_request(:post, SyncOrderJob::URL).to_return(status: 201)

  domain_exists

  renew_domain
end

When /^I reverse the renewal order$/ do
  reverse_renew_domain
end

Then /^domain must be renewed$/ do
  assert_domain_must_be_renewed
end

Then /^pending domain renewal order is created$/ do
  assert_renew_domain_order_created
end

Then /^transaction is successful$/ do
  assert_response_status_must_be_created
end

Then /^domain must no longer be renewed$/ do
  assert_domain_must_no_longer_be_renewed
end

Then /^renew domain fee must be added back to credits of non-admin partner$/ do
  assert_renew_domain_fee_must_be_added_back
end

Then /^renew domain must be synced to other systems$/ do 
  assert_requested :post, SyncOrderJob::URL, times: 1
end
