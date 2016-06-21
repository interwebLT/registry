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

Then /^I must see no host info$/ do
  assert_no_host_displayed
end
