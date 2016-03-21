When /^I try to view an existing contact info$/ do
  contact = FactoryGirl.create :contact

  get contact_path(contact.handle)
end

Then /^I must see the contact info$/ do
  expect(json_response).to eql 'contacts/contact/get_response'.json
end
