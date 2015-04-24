When /^I try to view my orders$/ do
  view_orders
end

When /^client sends order with no order details$/ do
  partner_authenticated

  create_order json_request: { currency_code: 'USD' }
end

When /^client sends invalid order$/ do
  partner_authenticated

  create_order json_request: {}
end

When /^I register a domain$/ do
  domain_does_not_exist
  contact_exists

  register_domain
end

When /^I register a domain with 2-level TLD$/ do
  domain_does_not_exist domain: TWO_LEVEL_DOMAIN
  contact_exists

  register_domain name: TWO_LEVEL_DOMAIN
end

When /^I register a domain with no domain name$/ do
  register_domain name: BLANK_DOMAIN_NAME
end

When /^I register a domain with no period$/ do
  register_domain period: BLANK_PERIOD
end

When /^I register a domain with no registrant handle$/ do
  register_domain registrant: BLANK_REGISTRANT
end

When /^I register a domain with no registered at$/ do
  register_domain registered_at: BLANK_REGISTERED_AT
end

When /^I register a domain with no partner$/ do
  contact_exists

  register_domain partner: NO_PARTNER
end

When /^I register a domain with non\-existing partner$/ do
  partner_does_not_exist NON_ADMIN_PARTNER

  register_domain
end

When /^I register a domain with non\-existing registrant$/ do
  contact_does_not_exist

  register_domain
end

When /^I register a domain with existing name$/ do
  domain_exists
  contact_exists

  register_domain
end

When /^I try to view the latest purchases in my zone$/ do
  view_latest_orders
end

Then /^domain must be registered under non\-admin partner$/ do
  assert_completed_register_domain_response

  assert_domain_must_be_registered
  assert_register_domain_activity_must_be_created
end

Then /^pending register domain order is created$/ do
  register_domain_order_must_be_created
end

Then /^domain with 2\-level TLD must be registered$/ do
  assert_completed_register_domain_response domain: TWO_LEVEL_DOMAIN

  assert_domain_must_be_registered domain: TWO_LEVEL_DOMAIN
end

Then /^I must see my orders$/ do
  assert_orders_displayed
end

Then /^I must not see any pending orders$/ do
  assert_pending_orders_not_displayed
end

Then /^I must see the latest orders$/ do
  assert_latest_orders_displayed
end
