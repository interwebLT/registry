
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

Then /^contact must be updated$/ do
  assert_contact_updated
  assert_update_contact_history_created
end
