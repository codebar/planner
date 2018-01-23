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
  sleep 4
end

When("I click to subscribe to a particuar region") do
  subscriptions_page.select_sub
  sleep 4
end

Then("I should be notified that I have succesfully subscribed for a particular region") do
  expect(subscriptions_page.confirm_subs_updated).to eq true
  sleep 4
  subscriptions_page.select_sub
  sign_in_page.sign_out_func
  github_logout_page.github_logout_func


end
