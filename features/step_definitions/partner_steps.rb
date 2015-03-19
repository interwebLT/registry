When /^I try to view a list of all partners$/ do
  view_partners
end

When /^I try to view the info of a partner$/ do
  view_partner_info
end

Then /^I must see a list of all partners$/ do
  assert_partners_displayed
end

Then /^I must see the info of the partner$/ do
  assert_partner_info_displayed
end
