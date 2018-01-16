Given("I am on a page") do
  visit('/')
end

When("I click link") do
  footer.click_code_of_conduct
end

Then("It works") do
  footer.click_code_of_conduct
end
