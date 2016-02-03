When /^I try to view contacts$/ do
  contact_exists
  other_contact_exists

  view_contacts
end

When /^I try to view the info of a contact$/ do
  contact_exists

  view_contact_info
end

Then /^I must see the info of the contact$/ do
  assert_contact_info_displayed
end

Then /^I must see all contacts$/ do
  assert_contacts_displayed
end

Then /^I must see no contacts$/ do
  assert_no_contacts_displayed
end

Then /^I must see no contact info$/ do
  assert_no_contact_displayed
end
