When /^I try to view an existing contact info$/ do
  contact = FactoryGirl.create :contact

  get contact_path(contact.handle)
end

When /^I try to view a non\-existing contact info$/ do
  get contact_path('dne')
end

Then /^I must see the contact info$/ do
  expect(json_response).to eql 'contacts/contact/get_response'.json
end

Then /^I must be notified that contact does not exist$/ do
  expect(last_response.status).to eql 404
end
