When /^I update a contact$/ do
  contact = create :contact

  patch contact_path(contact.handle), 'contact/patch_request'.json
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
  last_response.status.must_equal 200

  json_response.must_equal 'contact/patch_response'.json

  Contact.count.must_equal 1
  Contact.last.contact_histories.count.must_equal 2
end
