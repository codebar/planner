Given("I am on a page") do
  code_of_conduct_page.visit_code_of_conduct_page
  sleep 5
  code_of_conduct_page.find_code_of_conduct_title
  sleep 5
  # homepage.find_short_codebar_description
  # sleep 5
end

When("I click link") do
  pending
end

Then("It works") do
  pending
end
