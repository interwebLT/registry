When /^I try to view contacts$/ do
  contact_exists
  other_contact_exists

  view_contacts
end

Then /^I must see all contacts$/ do
  assert_contacts_displayed
end

Then /^I must see no contacts$/ do
  assert_no_contacts_displayed
end
