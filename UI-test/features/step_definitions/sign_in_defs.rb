Given("I am on the homepage") do
  sign_in.visit_homepage
  # pending # Write code here that turns the phrase above into concrete actions
end

Given("I have clicked on the sign in link") do
  sign_in.sign_in_link
  # pending # Write code here that turns the phrase above into concrete actions
end

When("i enter my github account details and press enter") do
  sign_in.enter_github_username
  sign_in.enter_github_psswrd
  sleep 2
  sign_in.confirm_github_details
  # pending # Write code here that turns the phrase above into concrete actions
end

Then("I am redirected to the dashbord page which includes my name as a link and a sidebar on the left hand side") do
  sign_in.confirm_redirection_dashboard
  sleep 2
  # pending # Write code here that turns the phrase above into concrete actions
end
