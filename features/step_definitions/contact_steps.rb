When /^I create a new contact$/ do
  contact_does_not_exist

  create_contact
end

When /^I create a new contact with empty request$/ do
  create_contact with: { json_request: EMPTY_REQUEST }
end

When /^I create a new contact under another partner$/ do
  contact_does_not_exist
  other_partner_exists

  create_contact with: { partner: OTHER_PARTNER }
end

When /^I create a new contact with existing handle$/ do
  contact_exists

  create_contact
end

When /^I create a new contact under another admin partner$/ do
  contact_does_not_exist
  other_admin_partner_exists

  create_contact with: { partner: OTHER_ADMIN_PARTNER }
end

When /^I create a new contact with empty partner$/ do
  contact_does_not_exist

  create_contact with: { partner: EMPTY_PARTNER }
end

When /^I create a new contact with non\-existing partner$/ do
  contact_does_not_exist
  other_partner_does_not_exist

  create_contact with: { partner: OTHER_PARTNER }
end

When /^I update a contact$/ do
  contact_exists

  update_contact
end

When /^I update a contact to another partner$/ do
  contact_exists

  update_contact with: { partner: OTHER_PARTNER }
end

When /^I update a contact that does not exist$/ do
  contact_does_not_exist

  update_contact
end

When /^I update a contact with a new handle$/ do
  contact_exists

  update_contact with: { handle: NEW_CONTACT_HANDLE }
end

When /^I update a contact with an existing handle$/ do
  contact_exists
  other_contact_exists

  update_contact with: { handle: OTHER_CONTACT_HANDLE }
end

When /^I update a contact that I do not own$/ do
  other_partner_exists
  contact_exists under: OTHER_PARTNER

  update_contact
end

When /^I try to view contacts$/ do
  contact_exists
  other_contact_exists
  
  view_contacts
end

Then /^I must see all contacts$/ do
  assert_contacts_displayed
end

Then /^contact must be created$/ do
  assert_contact_created
  assert_create_contact_history_created
end

Then /^contact must be updated$/ do
  assert_contact_updated
  assert_update_contact_history_created
end

