CREATE_CONTACT = Transform /^create a new contact(?: |)(.*?)$/ do |scenario|
  build_request scenario: scenario, resource: :contact, action: :post
end

When /^I (#{CREATE_CONTACT})$/ do |request|
  stub_request(:post, 'http://localhost:9001/contacts')
    .with(headers: headers, body: request.body)
    .to_return status: 201

  post contacts_path, request.json
end

When /^I create a new contact with existing handle$/ do
  create :contact

  post contacts_path, 'contacts/post_request'.json
end

Then /^contact must be created$/ do
  last_response.status.must_equal 201

  json_response.must_equal 'contacts/post_response'.json

  Contact.count.must_equal 1
  Contact.last.contact_histories.count.must_equal 1
end

Then /^create contact must be synced to other systems$/ do
  assert_requested :post, 'http://localhost:9001/contacts', times: 1
end

Then /^create contact must not be synced to other systems$/ do
  assert_not_requested :post, 'http://localhost:9001/contacts'
end
