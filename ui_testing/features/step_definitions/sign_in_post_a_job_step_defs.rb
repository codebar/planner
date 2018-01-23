Given("I click post a job in the menu tab") do
  sign_in_page.click_menu_tab
  sign_in_page.click_post_a_job
end

When("I submit the appropriate details") do
  sign_in_page.fill_in_job_title_field
  sign_in_page.fill_in_company_field
  sign_in_page.fill_in_location_field
  sign_in_page.fill_in_description_field
  sign_in_page.fill_in_link_to_field
  sign_in_page.click_submit_to_post_job
end

Then("I should see my posted job") do
  expect(sign_in_page.check_post_title).to eq("Test1")
end
