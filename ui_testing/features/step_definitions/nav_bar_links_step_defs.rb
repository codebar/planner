When("I click on Blog link") do
  codebar_homepage.click_blog_link
end

Then("I go to Medium page") do
  expect(current_url).to eq('https://medium.com/@codebar')
end

When("I click on Events link") do
  codebar_homepage.click_event_link
end

Then("I go to the events page") do
  expect(current_url).to eq('https://www.codebar.io/events')
end

When("I click on Tutorials link") do
  codebar_homepage.click_tutorials_link
end

Then("I go to the tutorials page") do
  expect(current_url).to eq('http://tutorials.codebar.io/')
end

When("I click on Coaches link") do
  codebar_homepage.click_coaches_link
end

Then("I go to Coaches page") do
  expect(current_url).to eq('https://www.codebar.io/coaches')
end

When("I click on Sponsors link") do
  codebar_homepage.click_sponsors_link
end

Then("I go to Sponsors page") do
  expect(current_url).to eq('https://www.codebar.io/sponsors')
end

When("I click on Jobs link") do
  codebar_homepage.click_jobs_link
end

Then("I go to Jobs page") do
  expect(current_url).to eq('https://www.codebar.io/jobs')
end
