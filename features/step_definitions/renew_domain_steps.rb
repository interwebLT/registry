Given /^I have registered a domain$/ do
  domain_does_not_exist
  contact_exists
  register_domain
end

When /^I renew my domain$/ do
  renew_domain
end

When /^I renew an existing domain$/ do
  domain_exists

  renew_domain
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
