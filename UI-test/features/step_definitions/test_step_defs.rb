Given("I am on a page") do
  homepage.visit_home_page

  sign_in.sign_in_link

  sign_in.enter_github_username

  sign_in.enter_github_psswrd

  sign_in.confirm_github_details

  invitations_page.visit_invitations_page
  sleep 4
  invitations_page.click_attended
  sleep 4
  # sleep 4
  # events_someslug_page.click_rsvp_coach
  # sleep 4
  # events_someslug_page.find_alert_box_attending
  # sleep 4
end

When("I click link") do
  pending
end

Then("It works") do
  pending
end
