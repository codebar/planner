Given("that I am already signed in") do
  homepage.visit_home_page
  sign_in_page.sign_in_func
end

And("I have clicked on an event on my dashboard") do
  events_page.click_events_link
  events_someslug_page.visit_events_slug_page
end

When("I confirm my attendance") do
  events_someslug_page.click_attend_student
  events_someslug_page.click_rsvp_student
end

Then("I should receive a notification saying that  a spot has been confirmed") do
  events_someslug_page.find_alert_box_attending
end

And("a record of my confirmation should be registed on codebar's side") do
  events_someslug_page.confirm_attending_label
end

And("the dashboard should indicate that I am attending that particular event") do
  homepage.visit_home_page
  events_someslug_page.confirm_attending_link
  sign_in_page.sign_out_func
  github_logout_page.github_logout_func
end
