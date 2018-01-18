Given("I am on a page") do
  homepage.visit_home_page
  sleep 5
  homepage.find_short_codebar_description
  sleep 5
end

When("I click link") do
  pending
end

Then("It works") do
  pending
end
