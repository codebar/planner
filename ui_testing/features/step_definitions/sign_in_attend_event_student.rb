Given("I click on a random subscription workshop link") do
  sign_in_page.click_random_workshop
end

When("I click on attend as student") do
  sign_in_page.click_attend_workshop_as_student
  sign_in_page.click_rsvp_workshop_as_student
end

Then("I should see the appropriate message displayed") do
  expect(sign_in_page.get_success_subscription_message).to include("Your spot has been confirmed for Android Development Workshop! We look forward to seeing you there.").or include("We are so sad you can't make it, but thanks for letting us know Francis.")
end

When("I click to cancel my spot") do
  sign_in_page.click_cancel_my_spot
end
