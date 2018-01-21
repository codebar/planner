Given("I am already signed in") do
  homepage.visit_home_page
  sign_in_page.sign_in_func
end

And("I have clicked on update your details section") do
  update_profile_page.open_sidebar_menu
  update_profile_page.click_update_details
end

When("I have edited my details in the form") do
  update_profile_page.edit_details_page
end

And("I have clicked save") do
  update_profile_page.save_update_profile
end

Then("the changes are reflected on my profile page") do
  update_profile_page.confirm_details_updated
end
