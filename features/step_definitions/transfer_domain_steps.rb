When /^I transfer a domain from another partner$/ do
  stub_request(:post, SyncOrderJob::URL).to_return(status: 201)
  
  other_partner_exists
  domain_exists partner: OTHER_PARTNER

  transfer_domain
end

Then /^domain must now be under my partner$/ do
  assert_domain_transferred
end
