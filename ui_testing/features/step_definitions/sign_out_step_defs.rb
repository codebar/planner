Given("I am on the Github page") do
  github.visit_github
end

When("I click on the icon") do
  github.click_profile_icon
end

When("I sign out") do
  github.click_sign_out
end

Then("I have signed out") do
  github.find_developer_text
end
