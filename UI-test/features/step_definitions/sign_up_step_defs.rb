Given("I am on the homepage") do
  homepage.visit_home_page
end

And("I have  clicked on the sign up button") do
  homepage.click_sign_up_student
  sleep 5
end

And("i have agreed that I meet the criteria") do
  pending
end

When("I click on the create account button") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I should be redirected to the github sign up page") do
  pending # Write code here that turns the phrase above into concrete actions
end
