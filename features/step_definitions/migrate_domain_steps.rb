When /^I migrate a domain into registry$/ do
  contact_exists

  migrate_domain
end

When /^I migrate a domain with (.*)$/ do |scenario|
  migrate_domain scenario: scenario
end

Then /^domain must be migrated under non-admin partner$/ do
  assert_completed_migrate_domain_response

  assert_domain_must_be_registered
  assert_register_domain_activity_must_be_created
end
