When("I click on My Profile") do
  sign_in_page.click_my_profile_on_menu
end

Then("I should be able to see my profile") do
  profile.find_title_profile
end
