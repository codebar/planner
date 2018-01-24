Given("I have the sidebar open") do
  homepage.visit_home_page
  sign_in_page.sign_in_func
  new_job_page.open_sidebar_menu
end

When("I have clicked manage subscriptions") do
  subscriptions_page.click_subs_link
end

And("I am redirected to the subscriptions page") do
  subscriptions_page.manage_subs_page
end

And("I have clicked to subscribe to a particular reigon") do
  subscriptions_page.select_sub
end

Then("I should be notified that I have been subscribed to that particular reigon") do
  subscriptions_page.confirm_subs_updated
  sign_in_page.sign_out_func
  github_logout_page.github_logout_func
end
