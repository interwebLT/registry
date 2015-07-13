When /I create a host entry under a non-admin partner$/ do
  create_host
end

When /I create a host entry with no partner$/ do
  create_host partner: NO_PARTNER
end

When /I create a host entry with non-existing partner$/ do
  partner_does_not_exist NON_ADMIN_PARTNER

  create_host
end

When /I create a host entry with other admin partner$/ do
  other_admin_partner_exists

  create_host partner: OTHER_ADMIN_PARTNER
end

When /I create a host entry with no host name$/ do
  create_host name: NO_HOST_NAME
end

When /I create a host entry with blank host name$/ do
  create_host name: BLANK_HOST_NAME
end

When /I create a host entry with existing host name$/ do
  host_exists

  create_host
end

When /^I try to view hosts$/ do
  host_with_addresses_exists

  view_hosts
end

When /^I try to view the info of a host$/ do
  host_with_addresses_exists

  view_host_info
end

Then /^I must see the info of the host$/ do
  assert_host_info_displayed
end

Then /^I must see all hosts$/ do
  assert_hosts_displayed
end

Then /^I must see no hosts$/ do
  assert_no_hosts_displayed
end

Then /host entry must be created under given partner$/ do
  assert_response_must_be_created_host

  assert_host_must_be_created
end
