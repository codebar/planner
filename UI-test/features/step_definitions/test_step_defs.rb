Given("I am on a page") do
  events_page.visit_events_page
  # sleep 4
  # events_page.click_events_link
  # sleep 4
  events_page.find_sponsors_images
  sleep 4
end

When("I click link") do
  pending
end

Then("It works") do
  pending
end
