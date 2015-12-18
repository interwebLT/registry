When /^I register a domain$/ do
  stub_request(:post, SyncOrderJob::URL).to_return(status: 201)

  domain_does_not_exist
  contact_exists

  register_domain
end

When /^I register a domain with 2-level TLD$/ do
  stub_request(:post, SyncOrderJob::URL).to_return(status: 201)

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

Then /^domain must be registered under non\-admin partner$/ do
  assert_completed_register_domain_response object: {:id=>1, :type=>"domain", :name=>"domain.ph"}

  assert_domain_must_be_registered
  assert_register_domain_activity_must_be_created
end

Then /^pending register domain order is created$/ do
  register_domain_order_must_be_created
end

Then /^domain with 2\-level TLD must be registered$/ do
  assert_completed_register_domain_response domain: TWO_LEVEL_DOMAIN, object: product(name: 'test.com.ph')

  assert_domain_must_be_registered domain: TWO_LEVEL_DOMAIN
end