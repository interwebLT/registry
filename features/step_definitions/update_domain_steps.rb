When /^I update all contact handles of my domain$/ do
  domain = FactoryGirl.create :domain

  patch domain_path(domain.name), 'domains/domain.ph/patch_all_contact_handles_request'.json
end

When /^I update the registrant handle of my domain$/ do
  domain = FactoryGirl.create :domain

  patch domain_path(domain.name), 'domains/domain.ph/patch_registrant_handle_request'.json
end

When /^I update the admin handle of my domain$/ do
  domain = FactoryGirl.create :domain

  patch domain_path(domain.name), 'domains/domain.ph/patch_admin_handle_request'.json
end

When /^I update the billing handle of my domain$/ do
  domain = FactoryGirl.create :domain

  patch domain_path(domain.name), 'domains/domain.ph/patch_billing_handle_request'.json
end

When /^I update the tech handle of my domain$/ do
  domain = FactoryGirl.create :domain

  patch domain_path(domain.name), 'domains/domain.ph/patch_tech_handle_request'.json
end

When /^I update a domain that does not exist$/ do
  domain = FactoryGirl.build :domain

  patch domain_path(domain.name), 'domains/domain.ph/patch_request'.json
end

When /^I update a domain before domain exists$/ do
  domain = FactoryGirl.create :domain

  stub_request(:get, 'http://localhost:9001/domains/domain.ph')
    .to_return(status: 404, body: 'common/404'.body).times(9)
    .to_return status: 200, body: 'domains/domain.ph/get_response'.body

  stub_request(:patch, 'http://localhost:9001/domains/domain.ph')
    .to_return status: 200, body: 'domains/domain.ph/patch_registrant_handle_response'.body

  patch domain_path(domain.name), 'domains/domain.ph/patch_registrant_handle_request'.json
end

When /^I update a domain where domain does not exist$/ do
  stub_request(:get, 'http://localhost:9001/domains/domain.ph')
    .to_return status: 404, body: 'common/404'.body
end

Then /^all contact handles of my domain must be updated$/ do
  expect(last_response).to have_attributes status: 200
  expect(json_response).to eql 'domains/domain.ph/patch_all_contact_handles_response'.json
end

Then /^the registrant handle of my domain must be updated$/ do
  expect(last_response).to have_attributes status: 200
  expect(json_response).to eql 'domains/domain.ph/patch_registrant_handle_response'.json
end

Then /^the admin handle of my domain must be updated$/ do
  expect(last_response).to have_attributes status: 200
  expect(json_response).to eql 'domains/domain.ph/patch_admin_handle_response'.json
end

Then /^the billing handle of my domain must be updated$/ do
  expect(last_response).to have_attributes status: 200
  expect(json_response).to eql 'domains/domain.ph/patch_billing_handle_response'.json
end

Then /^the tech handle of my domain must be updated$/ do
  expect(last_response).to have_attributes status: 200
  expect(json_response).to eql 'domains/domain.ph/patch_tech_handle_response'.json
end

Then /^domain must be updated$/ do
  expect(last_response).to have_attributes status: 200
  expect(json_response).to eql 'domains/domain.ph/patch_response'.json
end

Then /^update domain must be checked until available$/ do
  expect(WebMock).to have_requested(:get, 'http://localhost:9001/domains/domain.ph').times(10)
end

Then /^update domain must reach max retries$/ do
  domain = FactoryGirl.build :domain

  begin
    patch domain_path(domain.name), 'domains/domain.ph/patch_request'.json

    fail
  rescue Exception => e
    expect(e).to be_an_instance_of RuntimeError
  end
end
