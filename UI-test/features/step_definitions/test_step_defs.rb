Given("I am on a page") do
  student_guide_page.visit_student_guide_page
  sleep 4
  student_guide_page.find_student_guide_title
  sleep 4
end

When("I click link") do
  pending
end

Then("It works") do
  pending
end
