Given /^I am authenticated as administrator$/ do
  admin_authenticated
end

Given /^I am authenticated as partner$/ do
  partner_authenticated
end

Then /^error must be bad request$/ do
  assert_response_message_must_be_bad_request
end

Then /^error must be validation failed$/ do
  assert_response_message_must_be_validation_failed
end

Then /^error must be not found$/ do
  assert_response_message_must_be_not_found
end

Then /^validation error on (.*?) must be "(.*?)"$/ do |field, error|
  assert_validation_failed_errors_must_include field, error
end

Then /^latest object activity must be (.*?)$/ do |scenario|
  assert_latest_object_activity scenario: scenario
end

Then /^(.*?) fee must be deducted from credits of non-admin partner$/ do |scenario|
  assert_credits_must_be_deducted scenario: scenario
end
