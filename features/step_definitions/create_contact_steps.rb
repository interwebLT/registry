CREATE_CONTACT = Transform /^create a new contact(?: |)(.*?)$/ do |scenario|
  build_request scenario: scenario, resource: :contact, action: :post
end

When /^I (#{CREATE_CONTACT})$/ do |request|
  stub_request(:post, SyncCreateContactJob::URL).to_return(status: 201)

  post contacts_path, request.json
end

When /^I create a new contact with existing handle$/ do
  create :contact

  post contacts_path, 'contact/post_request'.json
end

When /^I create a new contact for another partner with existing handle$/ do
  create :contact

  post contacts_path, 'contact/admin_post_request'.json
end

Then /^contact must be created$/ do
  last_response.status.must_equal 201

  json_response.must_equal 'contact/post_response'.json

  Contact.count.must_equal 1
  Contact.last.contact_histories.count.must_equal 1
end
