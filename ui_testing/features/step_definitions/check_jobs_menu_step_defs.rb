And("I click on Jobs") do
 sign_in_page.click_jobs_on_menu
end

Then("I should be able to see all the jobs listed") do
 jobs.find_title_jobs
end
