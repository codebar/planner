When("I click on Twitter's icon in the footer") do
  footer.visit_twitter
end

Then("I am redirected to Twitter's page") do
  expect(current_url).to eq ('https://twitter.com/codebar')
end

When("I click on Github's icon in the footer") do
  footer.visit_github
end

Then("I am redirected to Github's page") do
  expect(current_url).to eq ('https://github.com/codebar')
end

When("I click on Slack's icon in the footer") do
  footer.visit_slack
end

Then("I am redirected to Slack's page") do
  expect(current_url).to eq ('https://codebar-slack.herokuapp.com/')
end

When("I click on Facebbok's icon in the footer") do
  footer.visit_facebook
end

Then("I am redirected to Facebook's page") do
  expect(current_url).to eq ('https://www.facebook.com/codebarHQ')
end
