Given("I am on the dashboard page") do
  navbar.visit_home_page
  sign_in_page.click_sign_in
  sign_in_page.fill_in_sign_in_username
  sign_in_page.fill_in_sign_in_password
  sign_in_page.click_sign_in_button
end

And("I click on the edit link next to subscriptions.") do

end

When("I click on any chapter student subscription") do

end

Then("I should see the appropriate success message informing the user has subscribed as a student") do

end

When("I click on any Chapter coaches subscription.") do

end

Then("I should see the appropriate success message informing the user has subscribed as a coach") do

end
