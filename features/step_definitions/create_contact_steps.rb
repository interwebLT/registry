When /^I create a new contact$/ do
  stub_request(:post, 'http://localhost:9001/contacts')
    .to_return status: 201, body: 'contacts/post_response'.body

  post contacts_path, 'contacts/post_request'.json
end

When /^I create a new contact with empty request$/ do
  post contacts_path, 'contacts/post_with_empty_request_request'.json
end

When /^I create a new contact with existing handle$/ do
  FactoryGirl.create :contact

  post contacts_path, 'contacts/post_request'.json
end

Then /^contact must be created$/ do
  expect(last_response.status).to eq 201
  expect(json_response).to eql 'contacts/post_response'.json

  expect(Contact.last).to have_attributes handle: 'contact'
  expect(Contact.last.contact_histories.last).to have_attributes handle: 'contact'
end

Then /^create contact must be synced to external registries$/ do
  expect(WebMock).to have_requested(:post, 'http://localhost:9001/contacts')
    .with headers: HEADERS, body: 'contacts/post_request'.json
end

Then /^create contact must not be synced to external registries$/ do
  expect(WebMock).not_to have_requested(:post, 'http://localhost:9001/contacts')
end
