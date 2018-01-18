Given("I am logged in") do
  sign_in.visit_homepage
  sign_in.sign_in_link
  sign_in.enter_github_username
  sign_in.enter_github_psswrd
  sign_in.confirm_github_details
  # pending # Write code here that turns the phrase above into concrete actions
end

When("I click on the list a job option in the menu") do
  job_post.open_sidebar_menu
  job_post.click_job_link
  # pending # Write code here that turns the phrase above into concrete actions
end

And("I am sent to a page where I can enter the deatils of the job") do
  job_post.post_a_job_page
  # pending # Write code here that turns the phrase above into concrete actions
end

Then("I should be able to input details of the job") do
  job_post.job_checkbox_work_details
  job_post.job_title_form_details
  job_post.job_company_form_details
  job_post.job_location_form_details
  job_post.job_description_form_details
  job_post.job_webpage_form_details
  job_post.job_day_sel_form
  sleep 2
  # pending # Write code here that turns the phrase above into concrete actions
end

Then("click submit to confirm the job") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("See a notification telling me the job posting is being reviewed") do
  pending # Write code here that turns the phrase above into concrete actions
end
