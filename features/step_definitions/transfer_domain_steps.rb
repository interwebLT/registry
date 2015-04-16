When /^I transfer a domain from another partner$/ do
  domain_exists
  other_partner_exists

  transfer_domain
end

Then /^domain must now be under my partner$/ do
  assert_domain_transferred
end
