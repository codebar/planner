Given("I am on a page") do
  sign_in.visit_homepage
  sign_in.sign_in_link
  sign_in.enter_github_username
  sign_in.enter_github_psswrd
  sign_in.confirm_github_details
  profile_page.visit_profile_page
  profile_page.find_profile_title
  sleep 10
end

When("I click link") do
  pending
end

Then("It works") do
  pending
end
