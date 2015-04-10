When /^I migrate a domain into registry$/ do
  contact_exists

  migrate_domain
end

Then /^domain must be migrated under non-admin partner$/ do
  assert_completed_migrate_domain_response

  assert_domain_must_be_registered
  assert_register_domain_activity_must_be_created
end

Then /^migrate domain fee must be deducted from credits of non-admin partner$/ do
  assert_migrate_domain_fee_must_be_deducted
end
