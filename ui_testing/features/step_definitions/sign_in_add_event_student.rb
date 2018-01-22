# Given("I click on a random subscription workshop link") do
#   sign_in_page.click_workshop_event
# end
#
# When("I click on attend as student") do
#   # if sign_in_page.find_cancel_my_spot_for_workshop?
#   #   sign_in_page.click_cancel_my_spot_for_workshop
#   #   driver.switch_to.alert.accept
#   # end
#   sign_in_page.find_attend_as_student_for_workshop
#   sign_in_page.click_attend_as_student_for_workshop
#   sign_in_page.click_rsvp_as_student_workshop
# end
#
# Then("I should see the appropriate message displayed") do
#   expect(sign_in_page.get_success_subscription_message).to include("Your spot has been confirmed for Android Development Workshop! We look forward to seeing you there.").or include("We are so sad you can't make it, but thanks for letting us know Francis.")
# end
Given("I click on a random subscription workshop link") do
  sign_in_page.click_workshop_event
end

When("I click on attend as student") do
  sign_in_page.find_attend_as_student_for_workshop
  sign_in_page.click_attend_as_student_for_workshop
  sign_in_page.click_rsvp_as_student_workshop
end

Then("I should see the appropriate message displayed") do
  expect(sign_in_page.get_success_subscription_message).to include("Your spot has been confirmed for Android Development Workshop! We look forward to seeing you there.").or include("We are so sad you can't make it, but thanks for letting us know Francis.")
end

Given("I am on at the dashboard page") do
  navbar.visit_home_page
  sign_in_page.click_sign_in
  # github.find_authorization
  # github.click_authorization
  sign_in_page.click_workshop_event
end

When("I click cancel my spot") do
  sign_in_page.find_cancel_my_spot_for_workshop
  sign_in_page.click_cancel_my_spot_for_workshop
  # sign_in_page.find_alert.accept
end
