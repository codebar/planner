Given("that I am already signed in") do
  sign_in.visit_homepage
  sign_in.sign_in_link
  sign_in.enter_github_username
  sign_in.enter_github_psswrd
  sign_in.confirm_github_details
  update_profile.visit_dashboard
  # pending # Write code here that turns the phrase above into concrete actions
end

Given("the sidebar is already open") do
  update_profile.open_sidebar_menu
  # pending # Write code here that turns the phrase above into concrete actions
end

Given("I have clicked the 'update your details' section") do
  update_profile.click_update_details
  # pending # Write code here that turns the phrase above into concrete actions
end

When("I have edited details displayed in the form") do
  update_profile.edit_details_page
  # pending # Write code here that turns the phrase above into concrete actions
end

When("I have pressed save") do
  update_profile.save_update_profile
  # pending # Write code here that turns the phrase above into concrete actions
end

Then("the changes are reflected on my profile page") do
  update_profile.confirm_details_updated
  # pending # Write code here that turns the phrase above into concrete actions
end
