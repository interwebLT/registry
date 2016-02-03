MIGRATE_DOMAIN = Transform /^migrate a domain into registry(?: |)(.*?)$/ do |scenario|
  build_request scenario: scenario, resource: :order, action: :create_migrate_domain
end

When /^I (#{MIGRATE_DOMAIN})$/ do |request|
  create :contact

  post migrations_path, request.json
end

Then /^domain must be migrated under non-admin partner$/ do
  last_response.status.must_equal 201

  Domain.exists? name: DOMAIN
  Domain.last.domain_activities.first.is_a? ObjectActivity::Create
end
