Given("I am in the tutorials page") do
  tutorials_page.visit_tutorials_page
end

When("I click Join the codebar community on Slack") do
  tutorials_page.visit_slack_community
end

Then("I am redirected to https://codebar-slack.herokuapp.com/") do
  page.driver.browser.switch_to.window(page.driver.browser.window_handles.last).to eq('https://codebar-slack.herokuapp.com/')
  # expect(current_url).switch_to.window

end

When(/^I press (.*)$/) do |a_link|
  tutorials_page.tutorials_link(a_link)
end

Then(/^The correspondent page opens (.*)$/) do |page_link|
  expect(current_url).to eq page_link
end
