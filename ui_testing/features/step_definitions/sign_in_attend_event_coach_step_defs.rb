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
