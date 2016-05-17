When /^I try to view my orders$/ do
  view_orders
end

When /^client sends order with no order details$/ do
  partner_authenticated

  create_order json_request: { currency_code: 'USD' }
end

When /^client sends invalid order$/ do
  partner_authenticated

  create_order json_request: {}
end

When /^I try to view the latest purchases in my zone$/ do
  view_latest_orders
end

Then /^I must see my orders$/ do
  assert_orders_displayed
end

Then /^I must not see any pending orders$/ do
  assert_pending_orders_not_displayed
end

Then /^I must see the latest orders$/ do
  assert_latest_orders_displayed
end

Then /I must see my orders that were refunded$/ do
  assert_refunded_orders_displayed
end

Then /^order must be synced to other systems$/ do
  assert_requested :post, 'http://localhost:9001/orders', times: 1
end

Then /^order must not be synced to other systems$/ do
  assert_not_requested :post, 'http://localhost:9001/orders', times: 1
end
