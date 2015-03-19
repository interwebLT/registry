When /^I add a host address entry to an existing host$/ do
  host_exists

  add_host_address
end

When /^I add a host address entry with missing address$/ do
  host_exists

  add_host_address address: NO_HOST_ADDRESS
end

When /^I add a host address entry with blank address$/ do
  host_exists

  add_host_address address: BLANK_HOST_ADDRESS
end

When /^I add a host address entry with missing type$/ do
  host_exists

  add_host_address type: NO_HOST_ADDRESS_TYPE
end

When /^I add a host address entry with blank type$/ do
  host_exists

  add_host_address type: BLANK_HOST_ADDRESS_TYPE
end

When /^I add a host address entry with invalid type$/ do
  host_exists

  add_host_address type: INVALID_HOST_ADDRESS_TYPE
end

When /^I add a host address entry with existing address$/ do
  host_exists
  host_address_exists

  add_host_address
end

When /^I add a host address entry for non-existing host$/ do
  host_does_not_exist

  add_host_address
end

When /^I add a host address entry which is also used by another host$/ do
  host_exists

  host_exists name: OTHER_HOST_NAME
  host_address_exists host: OTHER_HOST_NAME

  add_host_address
end

When /^I remove a host address entry from an existing host$/ do
  host_exists
  host_address_exists

  remove_host_address
end

When /^I try to remove a host address entry from a non-existing host$/ do
  host_does_not_exist

  remove_host_address
end

When /^I try to remove a host address entry that does not exist$/ do
  host_exists
  host_address_does_not_exist

  remove_host_address
end

Then /^host address must be created$/ do
  assert_response_must_be_created_host_address

  assert_host_address_must_be_created
end

Then /^host must no longer have host address entry$/ do
  assert_host_address_removed
end
