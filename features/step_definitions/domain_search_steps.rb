Given(/^I have the domains (.+)$/) do |domains_string|
  domains = domains_string.split(',').collect { |d| d.strip }
  domains.each do |domain|
    domain_exists domain: domain
  end
end

When(/^I search for (.+)$/) do |search_term|
  search_domains search_term
end

Then(/^I must see (\d+) domains$/) do |num_domains|
  assert_domains_count_must_be num_domains.to_i
end

When(/^I search second level domains for (.+)$/) do |search_term|
  search_second_level_domains search_term
end

Then(/^the search log should have grown$/) do
  DomainSearchLog.all.size.must_equal 1
end