Given("I am on a page") do
  footer.visit_homepage
end

When("I click link") do
  footer.click_chosen_link('Code of conduct')

end

Then("It works") do
  expect( title_search.title_check ).to eq 'abc'

end
