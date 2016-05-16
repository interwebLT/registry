Given /^I have an application token$/ do
  application = FactoryGirl.create :application

  header  'Authorization',
          ActionController::HttpAuthentication::Token.encode_credentials(application.token)
end

When /^I try to access secure data$/ do
  get domains_url
end

Then /^I must be able to view the data$/ do
  expect(last_response.status).to eql 200
end

Then /^I must not be able to view the data$/ do
  expect(last_response.status).to eql 404
end
