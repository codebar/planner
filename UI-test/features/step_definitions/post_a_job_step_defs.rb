Given("I am logged in") do
  homepage.visit_home_page
  sign_in_page.sign_in_func
end

When("I click on the list a job option in the menu") do
  new_job_page.open_sidebar_menu
  new_job_page.click_job_link
end

Then("I should be sent to a page where I can enter the deatils of the job") do
  new_job_page.post_a_job_page
end

And("I enter all the required fields for the job and submit") do
  new_job_page.job_checkbox_work_details
  new_job_page.job_title_form_details
  new_job_page.job_company_form_details
  new_job_page.job_location_form_details
  new_job_page.job_description_form_details
  new_job_page.job_webpage_form_details
  new_job_page.click_submit_button
end

And("I should be taken to a new page to confirm") do
  new_job_page.click_submit_link
end

And("I should be notifitief of my submission for a job posting") do
  new_job_page.job_post_success
  sleep 2
end
