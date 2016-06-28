When /^I register a domain$/ do
  FactoryGirl.create :contact

  stub_request(:get, 'http://localhost:9001/contacts/contact')
    .to_return status: 200, body: 'contacts/contact/get_response'.body

  stub_request(:post, 'http://localhost:9001/orders')
    .to_return status: 201, body: 'orders/post_register_domain_response'.body

  post orders_path, 'orders/post_register_domain_request'.json
end

When /^I register a domain with two-level TLD$/ do
  FactoryGirl.create :contact

  stub_request(:get, 'http://localhost:9001/contacts/contact')
    .to_return status: 200, body: 'contacts/contact/get_response'.body

  stub_request(:post, 'http://localhost:9001/orders')
    .to_return status: 201, body: 'orders/post_register_domain_with_two_level_tld_response'.body

  post orders_path, 'orders/post_register_domain_with_two_level_tld_request'.json
end

When /^I register a domain before registrant exists$/ do
  FactoryGirl.create :contact

  stub_request(:get, 'http://localhost:9001/contacts/contact')
    .to_return(status: 404, body: 'common/404'.body).times(9)
    .to_return status: 200, body: 'contacts/contact/get_response'.body

  stub_request(:post, 'http://localhost:9001/orders')
    .to_return status: 201, body: 'orders/post_register_domain_response'.body

  post orders_path, 'orders/post_register_domain_request'.json
end

When /^I register a domain where registrant does not exist$/ do
  stub_request(:get, 'http://localhost:9001/contacts/contact')
    .to_return(status: 404, body: 'common/404'.body)
end

When /^I register a domain with no domain name$/ do
  post orders_path, 'orders/post_register_domain_with_no_domain_name_request'.json
end

When /^I register a domain with no period$/ do
  post orders_path, 'orders/post_register_domain_with_no_period_request'.json
end

When /^I register a domain with no registrant handle$/ do
  post orders_path, 'orders/post_register_domain_with_no_registrant_handle_request'.json
end

Then /^domain must be registered$/ do
  expect(last_response.status).to eq 201
  expect(json_response).to eq 'orders/post_register_domain_response'.json

  expect(Domain.last).to have_attributes name: 'domain.ph'
end

Then /^domain with two-level TLD must be registered$/ do
  expect(last_response.status).to eq 201
  expect(json_response).to eq 'orders/post_register_domain_with_two_level_tld_response'.json

  expect(Domain.last).to have_attributes name: 'domain.com.ph'
end

Then /^register domain must be synced to external registries$/ do
  expect(WebMock).to have_requested(:post, 'http://localhost:9001/orders')
    .with headers: HEADERS, body: 'orders/post_register_domain_request'.json
end

Then /^register domain must not be synced to external registries$/ do
  expect(WebMock).not_to have_requested(:post, 'http://localhost:9001/orders')
end

Then /^register domain fee must be deducted$/ do
  assert_fee_deducted 70.00.money
end

Then /^registrant must be checked until available$/ do
  expect(WebMock).to have_requested(:get, 'http://localhost:9001/contacts/contact').times(10)
end

Then /^register domain must reach max retries$/ do
  begin
    post orders_path, 'orders/post_register_domain_request'.json

    fail
  rescue Exception => e
    expect(e).to be_an_instance_of RuntimeError
  end
end
