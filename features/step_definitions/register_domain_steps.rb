When /^I register a domain(?: with |)(?: |)(.*)$/ do |scenario|
  request =
    case scenario
    when '2-level TLD'          then 'order/register_domain_with_two_level_tld_request'
    when 'no domain name'       then 'order/register_domain_with_no_domain_name_request'
    when 'no period'            then 'order/register_domain_with_no_period_request'
    when 'no registrant handle' then 'order/register_domain_with_no_registrant_handle_request'
    when 'for another partner'  then 'order/admin_register_domain_request'
    when 'for another partner with no domain name'
      'order/admin_register_domain_with_no_domain_name_request'
    when 'for another partner with no period'
      'order/admin_register_domain_with_no_period_request'
    when 'for another partner with no registrant handle'
      'order/admin_register_domain_with_no_registrant_handle_request'
    when 'for another partner with no partner'
      'order/admin_register_domain_with_no_partner_request'
    when 'for another partner with non-existing partner'
      'order/admin_register_domain_with_non_existing_partner_request'
    when 'for another partner with non-existing registrant'
      'order/admin_register_domain_with_non_existing_registrant_request'
    else 'order/register_domain_request'
    end

  create :contact

  headers = {
    'Authorization' => 'Token token=alpha',
    'Content-Type'  => 'application/json',
    'Accept'        => 'application/json'
  }

  stub_request(:post, SyncOrderJob::URL)
    .with(body: request.json.to_json)
    .to_return status: 201

  post orders_path, request.json
end

Then /^domain must be registered$/ do
  json_response.must_equal 'order/register_domain_response'.json

  Domain.exists? name: DOMAIN
end

Then /^domain with 2-level TLD must be registered$/ do
  json_response.must_equal 'order/register_domain_with_two_level_tld_response'.json

  Domain.exists? name: TWO_LEVEL_DOMAIN
end

Then /^register domain fee must be deducted$/ do
  assert_fee_deducted 70.00.money
end

Then /^order must be synced to other systems$/ do
  assert_requested :post, SyncOrderJob::URL, times: 1
end
