When /^I update an existing contact$/ do
  contact = FactoryGirl.create :contact

  stub_request(:patch, 'http://localhost:9001/contacts/contact')
    .to_return status: 200, body: 'contacts/patch_request'.body

  patch contact_path(contact.handle), 'contacts/patch_request'.json
end

When /^I update a contact that does not exist$/ do
  contact = FactoryGirl.build :contact

  patch contact_path(contact.handle), 'contacts/patch_request'.json
end

When /^I update a contact that I do not own$/ do
  partner = FactoryGirl.create :partner, name: 'other'
  contact = FactoryGirl.create :contact, partner: partner

  patch contact_path(contact.handle), 'contacts/patch_request'.json
end

Then /^contact must be updated$/ do
  expect(last_response.status).to eq 200
  expect(json_response).to eql 'contacts/patch_response'.json

  expect(Contact.last).to have_attributes name: 'new_name'
  expect(Contact.last.contact_histories.count).to eq 2
  expect(Contact.last.contact_histories.last).to have_attributes name: 'new_name'
end

Then /^update contact must be synced to external registries$/ do
  expect(WebMock).to have_requested(:patch, 'http://localhost:9001/contacts/contact')
    .with headers: HEADERS, body: 'contacts/patch_request'.json
end

Then /^update contact must not be synced to external registries$/ do
  expect(WebMock).not_to have_requested(:patch, 'http://localhost:9001/contacts/contact')
end
