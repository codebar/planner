Given("that the sidebar open") do
  homepage.visit_home_page
  sign_in_page.sign_in_link
  sign_in_page.enter_github_username
  sign_in_page.enter_github_psswrd
  sign_in_page.confirm_github_details
  auth_page.auth_check
  navbar.click_menu
end

And("I press the invitations button") do
  navbar.click_aside_invitations
end

And("should see a list of upcoming and attended workshops") do
  invitations_page.find_attended_workshops_title
  invitations_page.find_upcoming_workshops_title
end

When("I click upcoming") do
  invitations_page.click_upcoming
  sleep 5
end

Then("I should see upcoming workshops") do
  expect(current_url).to eq invitations_page.get_upcoming_workshop_link
  sign_in_page.sign_out_func
  github_logout_page.github_logout_func
end
