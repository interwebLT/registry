When /^I try to view my credit history$/ do
  credit_exists

  view_credits
end

Then /^I must see my credit history$/ do
  assert_credits_displayed
end

Then /^I must not see any pending credit orders$/ do
  assert_pending_credits_not_displayed
end
