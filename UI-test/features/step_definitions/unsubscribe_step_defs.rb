Given("I am logged in and subscribed to a reigon") do
  homepage.visit_home_page
  sign_in_page.sign_in_func
  new_job_page.open_sidebar_menu
  subscriptions_page.click_subs_link
end

When("I select a reigon to unsubscribe") do
  subscriptions_page.select_sub
end

Then("I should be notified that I have been unsubscribed") do
  subscriptions_page.confirm_unsubs_updated
  sign_in_page.sign_out_func
  github_logout_page.github_logout_func
end
