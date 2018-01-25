Given("I am located on the homepage") do
  homepage.visit_home_page
  # sleep 3
end

And("I have  clicked on the sign up button") do
  homepage.click_sign_up_student
  # sleep 3
end

And("I have agreed that I understand that I meet the eligibility criteria") do
  sign_up_page.click_confirm
  # sleep 3
end

When("I click on the create account button") do
  sign_up_page.click_create_an_account
  sleep 3
end

Then("I should be redirected to the github sign up page") do
  expect(current_url).to include('https://github.com/join?')
  sleep 3
end
