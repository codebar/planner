# Given("I click on the twitter subscription workshop link") do
#   find(:css, "a[href='/workshops/652']").click
# end
#
# When("I click on attend as coach") do
#   find(:css, "a[href='/workshops/652/rsvp?role=Coach']").click
#   accept_alert do
#     find('a', :text => 'Join the waiting list').click
#   end
#   sleep 16
# end
#
# When("I click to cancel my place") do
#
# end
#
# Then("I should see the correct message displayed") do
#   expect(sign_in_page.get_success_subscription_message).to include("You have been added to the waiting list").or include("")
# end
Given("I click on the twitter subscription workshop link") do
  find(:css, "a[href='/workshops/652']").click
end

When("I click on attend as coach") do
  find(:css, "a[href='/workshops/652/rsvp?role=Coach']").click
end

Then("I should see the correct message displayed") do
  expect(sign_in_page.get_success_subscription_message).to include("You have already RSVPd or joined the waitlist for this workshop.")
end
