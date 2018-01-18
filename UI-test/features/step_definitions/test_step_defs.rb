Given("I am on a page") do
  homepage.visit_home_page
  # sleep 4
  sign_in.sign_in_link
  # sleep 4
  sign_in.enter_github_username
  # sleep 4
  sign_in.enter_github_psswrd
  # sleep 4
  # dashboard_page.visit_dashboard_page
  # sleep 4
  sign_in.confirm_github_details
  # sleep 4
  # dashboard_page.click_name_link
  sleep 4
  dashboard_page.find_dashboard_title
  sleep 4
end

When("I click link") do
  pending
end

Then("It works") do
  pending
end
