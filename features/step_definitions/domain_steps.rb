When /^I try to view my domains$/ do
  domain_exists

  view_domains
end

When /^I try to view the latest domains registered in my zone$/ do
  view_latest_domains
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

Then /^I must see my domains$/ do
  assert_domains_displayed
end

Then /^I must see the latest domains with newest first$/ do
  assert_latest_domains_displayed
end
