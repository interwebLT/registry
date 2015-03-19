When /^partner authenticates with (.*?)$/ do |credentials|
  authenticate_with credentials
end

Then /^partner receives authentication token$/ do
  assert_response_has_token_field
end

Then /^response to client must be bad credentials$/ do
  assert_response_message_must_be_bad_credentials
end
