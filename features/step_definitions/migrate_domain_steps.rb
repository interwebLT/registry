When /^I migrate a domain into registry$/ do
  create :contact

  post migrations_path, 'order/admin_migrate_domain_request'.json
end

When /^I migrate a domain with (.*)$/ do |scenario|
  scenarios = {
    'no domain name'        => 'order/admin_migrate_domain_with_no_domain_name_request',
    'no registrant handle'  => 'order/admin_migrate_domain_with_no_registrant_handle_request',
    'no registered at'      => 'order/admin_migrate_domain_with_no_registered_at_request',
    'no expires at'         => 'order/admin_migrate_domain_with_no_expires_at_request',
    'expires at before registered at' => 'order/admin_migrate_domain_with_expires_at_before_registered_at_request'
  }

  post migrations_path, scenarios[scenario].json
end

Then /^domain must be migrated under non-admin partner$/ do
  last_response.status.must_equal 201

  Domain.exists? name: DOMAIN
  Domain.last.domain_activities.first.is_a? ObjectActivity::Create
end
