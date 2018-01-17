When("I sign up as a student") do
  homepage.click_sign_up_student
end

And("I accept criterias") do
  newmember.click_sign_up_student
end

And("I login to GitHub") do
  github.fill_username('kalok9990')
  github.fill_password('Honey941')
  github.click_submit
end

Then("I will have signed up") do
  newmember.find_dashboard
end

When("I sign up as a coach") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("I host a workshop") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I get redirected to the email app") do
  pending # Write code here that turns the phrase above into concrete actions
end
