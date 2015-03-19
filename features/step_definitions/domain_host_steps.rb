When /^I add a domain host entry to an existing domain$/ do
  domain_exists
  host_exists

  add_domain_host
end

When /^I add a domain host entry with missing name$/ do
  domain_exists

  add_domain_host name: NO_HOST_NAME
end

When /^I add a domain host entry with blank name$/ do
  domain_exists

  add_domain_host name: BLANK_HOST_NAME
end

When /^I add a domain host entry with existing name$/ do
  domain_exists
  host_exists
  domain_host_exists

  add_domain_host
end

When /^I add a domain host entry with no matching host$/ do
  domain_exists
  host_does_not_exist

  add_domain_host
end

When /^I add a domain host entry for non-existing domain$/ do
  domain_does_not_exist

  add_domain_host
end

When /^I add a domain host entry which is also used by another domain$/ do
  domain_exists
  host_exists

  domain_exists domain: OTHER_DOMAIN
  domain_host_exists domain: OTHER_DOMAIN

  add_domain_host
end

When /^I remove a domain host entry from an existing domain$/ do
  domain_exists
  host_exists
  domain_host_exists

  remove_domain_host
end

When /^I remove a domain host entry of a non\-existing domain$/ do
  domain_does_not_exist

  remove_domain_host
end

When /^I remove a domain host entry that does not exist$/ do
  domain_exists
  domain_host_does_not_exist

  remove_domain_host
end

When /I remove all domain host entries of an existing domain$/ do
  domain_exists

  remove_all_domain_hosts
end

Then /^domain host entry must be created$/ do
  assert_response_must_be_created_domain_host

  assert_domain_host_must_be_created
  assert_add_domain_host_domain_activity_must_be_created
end

Then /^domain host entry must be removed$/ do
  assert_response_must_be_deleted_domain_host

  assert_domain_host_must_be_deleted
  assert_remove_domain_host_domain_activity_must_be_created
end
