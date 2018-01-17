When("I click on Blog link in the nav bar") do
  navbar.click_blog_link
end

Then("I go to Medium page") do
  expect(current_url).to eq('https://medium.com/@codebar')
end

When("I click on Events link in the nav bar") do
  navbar.click_event_link
end

Then("I go to the events page") do
  expect(current_url).to eq('https://www.codebar.io/events')
end

When("I click on Tutorials link in the nav bar") do
  navbar.click_tutorials_link
end

Then("I go to the tutorials page") do
  expect(current_url).to eq('http://tutorials.codebar.io/')
end

When("I click on Coaches link in the nav bar") do
  navbar.click_coaches_link
end

Then("I go to Coaches page") do
  expect(current_url).to eq('https://www.codebar.io/coaches')
end

When("I click on Sponsors link in the nav bar") do
  navbar.click_sponsors_link
end

Then("I go to Sponsors page") do
  expect(current_url).to eq('https://www.codebar.io/sponsors')
end

When("I click on Jobs link in the nav bar") do
  navbar.click_jobs_link
end

Then("I go to Jobs page") do
  expect(current_url).to eq('https://www.codebar.io/jobs')
end

When("I click on Donate link in the nav bar") do
  navbar.click_donate_link
end

Then("I go to Donate page") do
  expect(current_url).to eq('https://www.codebar.io/donations/new')
end
