When /^partner authenticates with (.*?)$/ do |scenario|
  FactoryGirl.create :partner

  credentials = {
    'valid credentials' => {  username: 'alpha',    password: 'password'  },
    'invalid username'  => {  username: 'invalid',  password: 'password'  },
    'invalid password'  => {  username: 'alpha',    password: 'invalid'   },
    'no username'       => {  username: nil,        password: 'password'  },
    'no password'       => {  username: 'alpha',    password: nil }
  }

  post authorizations_url, credentials[scenario]
end

Then /^partner receives authentication token$/ do
  assert_response_status_must_be_created

  json_response.include? :token
end

Then /^response to client must be bad credentials$/ do
  assert_response_status_must_be_unprocessable_entity

  assert_response_message 'Bad Credentials'
end
