When  /^I delete a domain that currently exists$/ do
  domain_exists

  delete_domain
end

Then  /^domain must no longer exist$/ do
  assert_domain_does_not_exist
end

Then  /^domain must now be in the deleted domain list$/ do
  assert_deleted_domain_exists
end
