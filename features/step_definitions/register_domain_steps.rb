When /^I register a domain(?: with |)(.*)$/ do |scenario|
  scenarios = {
    ''  => 'order/register_domain_request',
    '2-level TLD'           => 'order/register_domain_with_two_level_tld_request',
    'no domain name'        => 'order/register_domain_with_no_domain_name_request',
    'no period'             => 'order/register_domain_with_no_period_request',
    'no registrant handle'  => 'order/register_domain_with_no_registrant_handle_request'
  }

  create :contact

  post orders_url, scenarios[scenario].json
end

Then /^domain must be registered$/ do
  Domain.exists? name: DOMAIN
end

Then /^domain with 2-level TLD must be registered$/ do
  Domain.exists? name: TWO_LEVEL_DOMAIN
end

Then /^register domain fee must be deducted/ do
  assert_fee_deducted 70.00.money
end
