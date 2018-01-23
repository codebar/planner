

When(/^I click on a link in the navbar (.*)$/) do |link|
  navbar.click_navbar_link(link)
end

When(/^I click on the navbar menu then click a link in the aside (.*)$/) do |link|
  navbar.click_menu
  navbar.click_aside_link(link)
end

And ('I can logout') do
  github_logout_page.github_logout_func
end
