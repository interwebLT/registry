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

Then /^domain must be migrated into my partner$/ do
  expect(last_response.status).to eq 201

  expect(Domain.exists?(name: DOMAIN)).to be true
  expect(Domain.last.domain_activities.first).to be_kind_of ObjectActivity::Create
end

Then /^no fees must be deducted from my credits$/ do
  ledgers = @current_partner.ledgers.last

  expect(ledgers).not_to be nil
  expect(ledgers.activity_type).to eq 'use'
  expect(ledgers.amount).to eql 0.00.money
end
