Given("that I have the sidebar open") do
  homepage.visit_home_page
  sign_in_page.sign_in_link
  sign_in_page.enter_github_username
  sign_in_page.enter_github_psswrd
  sign_in_page.confirm_github_details
  navbar.click_menu
end

And("I have clicked managed subscriptions") do
  navbar.click_aside_manage_subscriptions
  sleep 3
end

And("I have been redirected to the subscriptions page") do
  url = URI.parse(current_url)
  expect(url).to eq URI.parse(subscriptions_page.subscriptions_page_link)
end

When("I click to suscribe to a particuar region") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I should be notified that I have succesfully suscribed for a particular region") do
  pending # Write code here that turns the phrase above into concrete actions
end
