When(/^I create a new user$/) do
  create_user
end

def create_user username: 'username', name: 'Some Name', email: 'test@email.com', password: 'password', registered_at: Time.now
  dummy = User.last

  params = {
    username: username,
    name: name,
    email: email,
    password: password,
    registered_at: registered_at
  }

  post partner_users_url(dummy.partner.id), params
end

Then /^user must be created$/ do
  User.find_by(username: 'username').wont_be_nil

  assert_response_status_must_be_ok
end

When /^I create a new user with empty request$/ do
  dummy = User.last

  params = {
  }

  post partner_users_url(dummy.partner.id), params
end

When /^I create a new user with existing email$/ do
  dummy = User.last

  create_user email: dummy.email
end


When /^I create a new user with empty name$/ do
  create_user name: nil
end

When /^I create a new user with empty email$/ do
  create_user email: nil
end

When /^I create a new user with empty password$/ do
  create_user password: nil
end

When /^I create a new user with no registration date$/ do
  create_user registered_at: nil
end

Then /^user must be created with the current time as the registration date$/ do
  user = User.find_by(username: 'username')
  user.wont_be_nil
  user.registered_at.wont_be_nil

  assert_response_status_must_be_ok
end