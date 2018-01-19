Given("that I have the sidebar open") do
  sign_in.visit_homepage
  sign_in.sign_in_link
  sign_in.enter_github_username
  sign_in.enter_github_psswrd
  sign_in.confirm_github_details
  manage_subs.open_sidebar_menu
  # pending # Write code here that turns the phrase above into concrete actions
end

And("I have clicked managed subscriptions") do
  manage_subs.click_subs_link
  sleep 2
  # pending # Write code here that turns the phrase above into concrete actions
end

And("I have been redirected to the subscriptions page") do
  manage_subs.manage_subs_page
  # pending # Write code here that turns the phrase above into concrete actions
end

When("I click to suscribe to a particuar region") do
  manage_subs.select_sub
  sleep 3
  # pending # Write code here that turns the phrase above into concrete actions
end

Then("I should be notified that I have succesfully suscribed for a particular region") do
  manage_subs.confirm_subs_updated
  # pending # Write code here that turns the phrase above into concrete actions
end
