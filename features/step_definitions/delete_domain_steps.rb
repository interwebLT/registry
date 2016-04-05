When  /^I delete a domain that currently exists$/ do
  domain = FactoryGirl.create :domain
  FactoryGirl.create :domain_host, product: domain.product

  domain.destroy
end

Then /^domain must no longer exist$/ do
  expect(Domain.last).to be nil
end

Then /^domain must now be in the deleted domain list$/ do
  expect(DeletedDomain.last).to have_attributes name: 'domain.ph'
end

Then /^deleted domain must not have domain hosts$/ do
  expect(DeletedDomain.last.product.domain_hosts).to be_empty
end
