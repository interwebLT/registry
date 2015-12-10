When(/^I replenish my credits via checkout$/) do
  assert_balance_is_money_type
  replenish_credits_via_checkout
end