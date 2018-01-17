Given("I am in the tutorials page") do
  tutorials_page.visit_tutorials_page
end

When(/^Clicking (.*)$/) do |a_link|
  tutorials_page.tutorials_link(a_link)
end

Then(/^I see the right page in a new tab (.*)$/) do |page_link|
  browser = page.driver.browser
  current_id = browser.window_handle
  tab_id = page.driver.find_window(page_link)
  browser.switch_to.window tab_id
  page.driver.browser.close
  browser.switch_to.window current_id
end

When(/^I press (.*)$/) do |a_link|
  tutorials_page.tutorials_link(a_link)
end

Then(/^The correspondent page opens (.*)$/) do |page_link|
  expect(current_url).to eq page_link
end
