CREDENTIALS = {
  'valid credentials' => {  username: 'alpha',    password: 'password'  },
  'invalid username'  => {  username: 'invalid',  password: 'password'  },
  'invalid password'  => {  username: 'alpha',    password: 'invalid'   },
  'no username'       => {  username: nil,        password: 'password'  },
  'no password'       => {  username: 'alpha',    password: nil }
}

def authenticate_with credentials
  create :user

  post authorizations_url, CREDENTIALS[credentials]
end

def assert_response_has_token_field
  assert_response_status_must_be_created

  json_response.include? :token
end

def assert_response_message_must_be_bad_credentials
  assert_response_status_must_be_unprocessable_entity

  assert_response_message 'Bad Credentials'
end
