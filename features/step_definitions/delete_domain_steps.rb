When  /^I delete a domain that currently exists$/ do
  domain_exists
  domain_host_exists

  delete_domain
end

Then  /^domain must no longer exist$/ do
  assert_domain_does_not_exist
end

Then  /^domain must now be in the deleted domain list$/ do
  assert_deleted_domain_exists
end

Then  /^deleted domain must not have domain hosts$/ do
  assert_deleted_domain_must_not_have_domain_hosts
end
