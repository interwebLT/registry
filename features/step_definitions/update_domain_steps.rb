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

  patch domain_path(domain.name), 'domains/domain.ph/patch_registrant_handle_request'.json
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
