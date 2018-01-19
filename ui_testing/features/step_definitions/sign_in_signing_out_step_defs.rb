Given("I am at the dashboard page") do
  navbar.visit_home_page
  sign_in_page.click_sign_in
end

And("I click on the menu tab") do
  sign_in_page.click_menu_tab
end

When("I click on the Sign out link") do
sign_in_page.click_sign_out_link
end

Then("I should successfully be signed out.") do
  expect(current_url).to eq("http://www.codebar.io/")
end
