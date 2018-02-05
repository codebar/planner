Given("I am on the Donate page") do
  navbar.visit_home_page
  navbar.click_donate_link
end

When("I fill the form") do
  donation.fill_name('Sam')
  donation.fill_amount('1')
end

When("I donate") do
  donation.click_donate
end

Then("it will ask for my bank details") do
  donation.find_pop_up
  donation.find_modal
end
