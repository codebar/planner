
Given("I am on a page") do
  homepage.visit_home_page
end

When("I click link") do

  navbar.click_navbar_link('Tutorials')

end

Then("It works") do

  tutorials.click_tutorial_link('Getting started guide for students')
  expect(title_search.title_check).to eq('Setting up your computer for codebar')
end
