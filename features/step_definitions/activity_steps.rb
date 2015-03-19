When /^I try to view all activities$/ do
  view_activities
end

Then /^I must see all activities$/ do
  assert_activities_displayed
end
