When /^I migrate a domain into registry for another partner$/ do
  create :contact

  post migrations_path, 'orders/admin_post_migrate_domain_request'.json
end

When /^I migrate a domain into registry for another partner with no domain name$/ do
  create :contact

  post migrations_path, 'orders/admin_post_migrate_domain_with_no_domain_name_request'.json
end

When /^I migrate a domain into registry for another partner with no registrant handle$/ do
  create :contact

  post migrations_path, 'orders/admin_post_migrate_domain_with_no_registrant_handle_request'.json
end

When /^I migrate a domain into registry for another partner with no registered at$/ do
  create :contact

  post migrations_path, 'orders/admin_post_migrate_domain_with_no_registered_at_request'.json
end

When /^I migrate a domain into registry for another partner with no expires at$/ do
  create :contact

  post migrations_path, 'orders/admin_post_migrate_domain_with_no_expires_at_request'.json
end

When /^I migrate a domain into registry for another partner with expires at before registered at$/ do
  create :contact

  post migrations_path, 'orders/admin_post_migrate_domain_with_expires_at_before_registered_at_request'.json
end

Then /^domain must be migrated under non-admin partner$/ do
  last_response.status.must_equal 201

  Domain.exists? name: DOMAIN
  Domain.last.domain_activities.first.is_a? ObjectActivity::Create
end
