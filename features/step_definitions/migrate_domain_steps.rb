When /^I migrate my domain into registry$/ do
  create :contact

  post migrations_path, 'migrations/post_request'.json
end

When /^I migrate a domain into registry with no domain name$/ do
  create :contact

  post migrations_path, 'migrations/post_with_no_domain_name_request'.json
end

When /^I migrate a domain into registry with no registrant handle$/ do
  create :contact

  post migrations_path, 'migrations/post_with_no_registrant_handle_request'.json
end

When /^I migrate a domain into registry with no registered at$/ do
  create :contact

  post migrations_path, 'migrations/post_with_no_registered_at_request'.json
end

When /^I migrate a domain into registry with no expires at$/ do
  create :contact

  post migrations_path, 'migrations/post_with_no_expires_at_request'.json
end

When /^I migrate a domain into registry with expires at before registered at$/ do
  create :contact

  post migrations_path, 'migrations/post_with_expires_at_before_registered_at_request'.json
end

When /^I migrate a domain into registry with no authcode$/ do
  create :contact

  post migrations_path, 'migrations/post_with_no_authcode_request'.json
end

Then /^domain must be migrated into my partner$/ do
  expect(last_response.status).to eq 201

  expect(Domain.last).to have_attributes  name:               'domain.ph',
                                          registrant_handle:  'contact',
                                          registered_at:      '2016-06-07 10:00:00 AM'.in_time_zone,
                                          expires_at:         '2018-06-07 10:00:00 AM'.in_time_zone,
                                          authcode:           '123456789ABCDEF'

  expect(Domain.last.domain_activities.first).to be_kind_of ObjectActivity::Create
end
