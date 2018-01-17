Given("I am on the landing page") do
  navbar.visit_home_page
end

When("I click on the logo") do
  navbar.click_codebar_logo
end

Then("I return to the homepage") do
  expect(current_url).to eq('https://www.codebar.io/')
end
