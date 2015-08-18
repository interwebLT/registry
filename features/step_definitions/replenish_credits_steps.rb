When(/^I replenish my credits$/) do
  replenish_credits
end

Then(/^my balance should have changed$/) do
  assert_balance_changed
end