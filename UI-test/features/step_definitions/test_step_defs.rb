Given("I am on a page") do
  footer.visit_homepage
end

When("I click link") do
  footer.click_chosen_link('facebook')

end

Then("It works") do
  expect(find('h1').text).to eq 'abc'
end
