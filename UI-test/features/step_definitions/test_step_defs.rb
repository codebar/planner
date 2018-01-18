Given("I am on a page") do
  coaches_page.visit_coaches_page
  sleep 5
  coaches_page.find_coaches_title
  sleep 5
end

When("I click link") do
  pending
end

Then("It works") do
  pending
end
