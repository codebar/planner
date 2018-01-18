Given("I am on a page") do
  footer.visit_homepage
end

When("I click link") do
  footer.click_chosen_link('Donate')
  footer.click_chosen_link('slack')
  footer.visit_homepage
  footer.click_chosen_link('facebook')
  footer.visit_homepage
  footer.click_chosen_link('github')
  footer.visit_homepage
  footer.click_chosen_link('twitter')
end

Then("It works") do
  pending
end
