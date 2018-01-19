Given("I start at the dashboard page") do
  navbar.visit_home_page
  sign_in_page.click_menu_tab
  sign_in_page.click_dashboard_in_menu_tab
end

When("I click on any chapter coach subscription") do
  sign_in_page.click_barcelona_coach_subscription
end

Then("I should see the appropriate success message informing the user has subscribed or unsubscriped as a coach") do
  expect(sign_in_page.get_success_subscription_message).to include("You have subscribed to Barcelona's Coaches group").or include("You have unsubscribed from Barcelona's Coaches group")
end
