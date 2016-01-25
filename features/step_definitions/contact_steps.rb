When /^I create a new contact$/ do
  stub_request(:post, SyncCreateContactJob::URL).to_return(status: 201)

  create_contact
end

When /^I create a new contact with empty request$/ do
  create_contact with: { json_request: EMPTY_REQUEST }
end

When /^I create a new contact under another partner$/ do
  other_partner_exists

  create_contact with: { partner: OTHER_PARTNER }
end

When /^I create a new contact with existing handle$/ do
  contact_exists

  create_contact
end

When /^I create a new contact under another admin partner$/ do
  other_admin_partner_exists

  create_contact with: { partner: OTHER_ADMIN_PARTNER }
end

When /^I create a new contact with empty partner$/ do
  create_contact with: { partner: EMPTY_PARTNER }
end

When /^I create a new contact with non\-existing partner$/ do
  other_partner_does_not_exist

  create_contact with: { partner: OTHER_PARTNER }
end

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

Then /^contact must be created$/ do
  assert_contact_created
  assert_create_contact_history_created
end
