When("I sign up as a student") do
  homepage.click_sign_up_student
end

And("I accept criterias") do
  newmember.click_sign_up_student
end

And("I submit the details") do
  student_details.fill_first_name("Sam")
  student_details.fill_surname("Hayes")
  student_details.fill_pronouns("he")
  student_details.fill_email("sam@fillup.com")
  student_details.fill_description("I have done tests")
  student_details.submit
  student_details.done
end

Then("I will have signed up") do
  expect(find_profile).to include("My Profile")
end

When("I sign up as a coach") do
  pending # Write code here that turns the phrase above into concrete actions
end

And("I login to GitHub") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("I host a workshop") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I get redirected to the email app") do
  pending # Write code here that turns the phrase above into concrete actions
end
