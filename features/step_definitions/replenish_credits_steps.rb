When(/^I replenish my credits$/) do
  assert_balance_is_money_type
  replenish_credits
end

Then(/^my balance should have changed$/) do
  assert_balance_changed
end