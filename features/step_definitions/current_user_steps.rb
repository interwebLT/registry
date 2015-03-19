When /^I try to view my partner information$/ do
  view_current_partner
end

Then /^I must see my partner information$/ do
  assert_current_partner_info_displayed
end
