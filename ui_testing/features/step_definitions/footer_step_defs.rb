Given("I am in the homepage") do
  footer.visit_home_page
end

When("I click in Code of Conduct in the footer") do
  footer.visit_code_of_conduct.click
end

Then("I am redirected to the Code of Conduct page") do
  expect(current_url).to eq('https://www.codebar.io/code-of-conduct')
end

When("I click in Tutorials in the footer") do
  footer.visit_tutorials
end

Then("I am redirected to the Tutorials page") do
  expect(current_url).to eq('http://tutorials.codebar.io/')
end

When("I click in Student Guide in the footer") do
  footer.visit_student_guide.click
end

Then("I am redirected to the Student guide page") do
  expect(current_url).to eq('https://www.codebar.io/student-guide')
end

When("I click in Donate in the footer") do
  footer.visit_donate
end

Then("I am redirected to the Donates guide page") do
  expect(current_url).to eq('https://www.codebar.io/donations/new')
end

When("I click in Becoming a Sponsor in the footer") do
  footer.visit_becoming_sponsor.click
end

Then("I am redirected to the Becoming a Sponsor page") do
  expect(current_url).to eq('http://manual.codebar.io/becoming-a-sponsor')
end

When("I click in FAQ in the footer") do
  footer.visit_faq.click
end

Then("I am redirected to the FAQ page") do
  expect(current_url).to eq('https://www.codebar.io/faq')
end

When("I click in Blog in the footer") do
  footer.visit_blog
end

Then("I am redirected to the Blog page") do
  expect(current_url).to eq('https://medium.com/the-codelog')
end

When("I click in Events in the footer") do
  footer.visit_events
end

Then("I am redirected to the Events page") do
  expect(current_url).to eq('https://www.codebar.io/events')
end

When("I click in Jobs in the footer") do
  footer.visit_jobs
end

Then("I am redirected to the Jobs page") do
  expect(current_url).to eq('https://www.codebar.io/jobs')
end
