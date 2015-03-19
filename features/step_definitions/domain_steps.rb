When /^I update all contact handles of my domain$/ do
  domain_exists
  contact_exists

  update_domain_contact registrant_handle: CONTACT_HANDLE,
                        admin_handle: CONTACT_HANDLE,
                        billing_handle: CONTACT_HANDLE,
                        tech_handle: CONTACT_HANDLE
end

When /^I update the registrant handle of my domain$/ do
  domain_exists
  contact_exists

  update_domain_contact registrant_handle: CONTACT_HANDLE
end

When /^I update the admin handle of my domain$/ do
  domain_exists
  contact_exists

  update_domain_contact admin_handle: CONTACT_HANDLE
end

When /^I update the billing handle of my domain$/ do
  domain_exists
  contact_exists

  update_domain_contact billing_handle: CONTACT_HANDLE
end

When /^I update the tech handle of my domain$/ do
  domain_exists
  contact_exists

  update_domain_contact tech_handle: CONTACT_HANDLE
end

When /^I update a domain that does not exist$/ do
  domain_does_not_exist

  update_domain_contact registrant_handle: CONTACT_HANDLE
end

When /^I update an existing domain (?:to|with) (.*)$/ do |scenario|
  domain_exists

  update_domain scenario: scenario
end

When /^I update an existing domain that has (.*) set to (.*)$/ do |status, scenario|
  domain_exists
  domain_changes_not_allowed status: status

  update_domain scenario: scenario
end

When /^I try to view my domains$/ do
  domain_exists

  view_domains
end

When /^I try to view the info of one of my domains$/ do
  domain_exists

  view_domain_info
end

When /^I try to view the latest domains registered in my zone$/ do
  view_latest_domains
end

Then /^all contact handles of my domain must be updated$/ do
  assert_response_must_be_updated_domain with: {
    registrant_handle: CONTACT_HANDLE,
    admin_handle: CONTACT_HANDLE,
    billing_handle: CONTACT_HANDLE,
    tech_handle: CONTACT_HANDLE
  }
end

Then /^the registrant handle of my domain must be updated$/ do
  assert_response_must_be_updated_domain with: { registrant_handle: CONTACT_HANDLE }
end

Then /^the admin handle of my domain must be updated$/ do
  assert_response_must_be_updated_domain with: { admin_handle: CONTACT_HANDLE }
end

Then /^the billing handle of my domain must be updated$/ do
  assert_response_must_be_updated_domain with: { billing_handle: CONTACT_HANDLE }
end

Then /^the tech handle of my domain must be updated$/ do
  assert_response_must_be_updated_domain with: { tech_handle: CONTACT_HANDLE }
end

Then /^domain status must have ([a-zA-Z]*) ([a-zA-Z]*)$/ do |status, flag|
  field = status.underscore.to_sym
  status_flag = true  if flag == 'enabled'
  status_flag = false if flag == 'disabled'

  assert_response_must_be_updated_domain with: { field => status_flag }
end

Then /^domain status must not be client hold$/ do
  assert_domain_status_must_not_be_client_hold
end

Then /^domain status must be ok$/ do
  assert_domain_status_must_be_ok
end

Then /^domain status must be inactive$/ do
  assert_domain_status_must_be_inactive
end

Then /^domain must not have domain hosts by default$/ do
  assert_domain_must_not_have_hosts
end

Then /^domain status (.*?) must be (.*?)$/ do |status, action|
  assert_response_status_must_be_ok

  assert_domain_status_response status: status, action: action
end

Then /^I must see the info of my domain$/ do
  assert_domain_info_displayed
end

Then /^I must see my domains$/ do
  assert_domains_displayed
end

Then /^I must see the latest domains with newest first$/ do
  assert_latest_domains_displayed
end
