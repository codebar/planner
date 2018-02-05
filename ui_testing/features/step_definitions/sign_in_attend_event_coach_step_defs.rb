Given("I click on the twitter subscription workshop link") do
  sign_in_page.click_monthly_january_workshop
end

Then("I should be taken to the correct page") do
  expect(current_url).to eq("http://www.codebar.io/meetings/monthly-jan-2018")
end
