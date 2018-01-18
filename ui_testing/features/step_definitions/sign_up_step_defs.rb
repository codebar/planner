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

Then("I will have signed up as a student") do
  if github.find_authorization
    github.click_authorization
  end
  newmember.find_dashboard
end

When("I sign up as a coach") do
  homepage.click_sign_up_coach
  newmember.click_sign_up_coach
end

Then("I will have signed up as a coach") do
  if github.find_authorization
    github.click_authorization
  end
  newmember.find_profile
end

When("I host a workshop") do
  homepage.click_host_workshop
end

Then("I get redirected to the email app") do
  expect(homepage.check_mail_app).to include('Mail')
end
