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
  find(:css, "a[href='/meetings/monthly-jan-2018']").click
end
#
# When("I click on attend as coach") do
#   find(:css, "a[href='/workshops/652/rsvp?role=Coach']").click
# end

Then("I should be taken to the correct page") do
  expect(current_url).to eq("http://www.codebar.io/meetings/monthly-jan-2018")
end
