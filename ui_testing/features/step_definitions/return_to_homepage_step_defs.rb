Given("I am on the landing page") do
  codebar_homepage.visit_home_page
end

When("I click on the logo") do
  codebar_homepage.click_codebar_logo
end

Then("I return to the homepage") do
  expect(current_url).to eq('https://www.codebar.io/')
end
