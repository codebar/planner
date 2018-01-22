
Given("I click on the tutorials navbar link") do
  navbar.click_navbar_link('Tutorials')
end

When(/^I click on a tutorial (.*)$/) do |link|
  tutorials_index_page.click_tutorial_link(link)
end

Then("I can return to the previous page with a link") do
  tutorials_page.go_back
  expect(current_url).to eq('http://tutorials.codebar.io/')
end
