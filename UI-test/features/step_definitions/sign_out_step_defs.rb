Given("that I am already logged in to codebar") do
  homepage.visit_home_page
  sign_in_page.sign_in_link
  sign_in_page.enter_github_username
  sign_in_page.enter_github_psswrd
  sign_in_page.confirm_github_details
end

When("I click the sign out button") do
  navbar.click_menu
  navbar.click_aside_sign_out
end

Then("be redirected to the hompage") do
  homepage.find_short_codebar_description
end

And("I should be signed out of my account") do
  navbar.click_sign_in
  url = URI.parse(current_url)
  expect(url).to eq URI.parse(sign_in_page.sign_in_page_link)
end
