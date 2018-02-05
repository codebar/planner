Given("I am in the Events page") do
  events_page.visit_events_page
end

When("I look at the page content") do
  events_page.events_page_content
end

Then("I can see a list of all events") do
  events_page.list_events
end

And("I click in Workshop or Event") do
  if events_page.find_workshop
    events_page.click_workshop
  else
    events_page.click_workshop
  end
end

When("I am redirected to that event page") do
  events_page.visit_event
end

Then("I can see the title, company hosting the event, and location") do
  events_page.event_details
end

When("I click in Workshop or Event and sign up") do
  if events_page.find_workshop
    events_page.click_workshop
  else
    events_page.click_event
  end
  events_page.click_sign_up
end

When("I sign in and click Invitations on the Menu") do
  sign_in_page.click_sign_in
  sign_in_page.click_menu_tab
  sign_in_page.click_invitations
end

When("I click in Workshop or Event and log in") do
  if events_page.find_workshop
    events_page.click_workshop
  else
    events_page.click_event
  end
  events_page.click_login
end

And("I click attend as a coach or a student") do
  if events_page.find_student
    events_page.click_student
  elsif events_page.find_coach
    events_page.click_coach
  else sign_up_page.find_member_name
    sign_up_page.full_form
  end
end

And("I select the event I want to cancel") do
  invitations_page.event_to_cancel
end

When("I click Sign up as a coach") do
  events_page.click_button(" coach")
end

When("I click Sign up as a student") do
  events_page.click_button(" student")
end

When("I choose I can no longer attend") do
  invitations_page.cancel_attendance
end

When("I choose what I want to work on and press Attend") do
  events_page.select_option.click
end

Then("I am redirected to my dashboard page") do
  if github.find_authorization
    github.click_authorization
  end
  sign_in_page.find_dashboard
end

Then("I can see a message Thanks for getting back to us") do
  events_page.thanks_message
end

Then("I can see the message We are so sad you can't make it, but thanks for letting us know") do
  invitations_page.cancelled_message
end
