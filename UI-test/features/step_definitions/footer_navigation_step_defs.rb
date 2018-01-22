
Given("I am on the homepage") do
  homepage.visit_home_page
end

When(/^I click on a link in the footer (.*)$/) do |link|
  footer.click_footer_link(link)
end

Then(/^I am sent to a page with the correct title (.*)$/) do |title|
  expect(title_search.title_check).to eq(title)

end
