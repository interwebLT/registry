When /^I view the info of the current partner$/ do
  get user_index_path
end

Then /^I must see my partner info$/ do
  expect(last_response.status).to eql 200

  expect(json_response.merge(partner_id: 1, token: 'abcd123456')).to eql 'user/get_response'.json
end
