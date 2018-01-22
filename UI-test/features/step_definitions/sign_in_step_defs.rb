Given("I am on the Homepage") do
  homepage.visit_home_page
end

And("I have clicked the sign in link") do
  sign_in_page.sign_in_link
end

When("I enter my Github account details and press enter") do
  sign_in_page.enter_github_username
  sign_in_page.enter_github_psswrd
  sign_in_page.confirm_github_details
end

Then("I am redirected to my profile page which has a button to the menu") do
  sign_in_page.confirm_redirection_dashboard
end
