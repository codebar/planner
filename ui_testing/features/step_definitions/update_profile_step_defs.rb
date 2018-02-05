Given("I am in the Update Profile page") do
  update_profile.visit_update_profile
  github.fill_username(ENV['GITHUB_USERNAME'])
  github.fill_password(ENV['GITHUB_PASSWORD'])
  github.click_submit
  sign_in_page.click_menu_tab
  sign_in_page.click_update_profile
  update_profile.visit_update_profile
end

When("I change the about me section") do
  update_profile.fill_aboutme
end

And("press Save") do
  update_profile.click_save
end

Then("I can see my updated profile with a message Your details have been updated") do
  expect(update_profile.confirmation_message).to include(' Your details have been updated.')
end
