When /^I update an existing contact$/ do
  contact = FactoryGirl.create :contact

  stub_request(:get, 'http://localhost:9001/contacts/contact')
    .to_return status: 200, body: 'contacts/contact/get_response'.body

  stub_request(:patch, 'http://localhost:9001/contacts/contact')
    .to_return status: 200, body: 'contacts/contact/patch_request'.body

  patch contact_path(contact.handle), 'contacts/contact/patch_request'.json
end

When /^I update a contact that does not exist$/ do
  contact = FactoryGirl.build :contact

  patch contact_path(contact.handle), 'contacts/contact/patch_request'.json
end

When /^I update a contact that I do not own$/ do
  partner = FactoryGirl.create :partner, name: 'other'
  contact = FactoryGirl.create :contact, partner: partner

  patch contact_path(contact.handle), 'contacts/contact/patch_request'.json
end

When /^I update a contact before contact exists$/ do
  contact = FactoryGirl.create :contact

  stub_request(:get, 'http://localhost:9001/contacts/contact')
    .to_return(status: 404, body: 'common/404'.body).times(9)
    .to_return status: 200, body: 'contacts/contact/get_response'.body

  stub_request(:patch, 'http://localhost:9001/contacts/contact')
    .to_return status: 200, body: 'contacts/contact/patch_request'.body

  patch contact_path(contact.handle), 'contacts/contact/patch_request'.json
end

When /^I update a contact where contact does not exist$/ do
  stub_request(:get, 'http://localhost:9001/contacts/contact')
    .to_return(status: 404, body: 'common/404'.body)
end

Then /^contact must be updated$/ do
  expect(last_response).to have_attributes status: 200
  expect(json_response).to eql 'contacts/contact/patch_response'.json

  expect(Contact.last).to have_attributes name: 'new_name'
  expect(Contact.last.contact_histories.count).to eq 2
  expect(Contact.last.contact_histories.last).to have_attributes name: 'new_name'
end

Then /^update contact must be synced to external registries$/ do
  expect(WebMock).to have_requested(:patch, 'http://localhost:9001/contacts/contact')
    .with headers: HEADERS, body: 'contacts/contact/patch_request'.json
end

Then /^update contact must not be synced to external registries$/ do
  expect(WebMock).not_to have_requested(:patch, 'http://localhost:9001/contacts/contact')
end

Then /^contact must be checked until available$/ do
  expect(WebMock).to have_requested(:get, 'http://localhost:9001/contacts/contact').times(10)
end

Then /^update contact must reach max retries$/ do
  contact = FactoryGirl.build :contact

  begin
    patch contact_path(contact.handle), 'contacts/contact/patch_request'.json

    fail
  rescue Exception => e
    expect(e).to be_an_instance_of RuntimeError
  end
end
