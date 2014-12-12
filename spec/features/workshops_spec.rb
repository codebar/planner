require 'spec_helper'

feature 'Viewing a workshop page' do

  let(:workshop) { Fabricate(:sessions) }
  let(:member) { Fabricate(:member) }

  scenario "A logged-out user can view an event" do
    visit workshop_path workshop

    expect(page).to be
  end

  scenario "A logged-in user can view an event" do
    login member
    visit workshop_path workshop

    expect(page).to be
  end

  scenario "A logged-out user viewing an event is invited to sign up or sign in" do
    visit workshop_path workshop

    expect(page).to have_content("Sign up")
    expect(page).to have_content("Log in")
  end

  scenario "A logged-in user viewing a past event cannot interact with that event"

  scenario "A logged-in user viewing a future event with student space can register to attend" do
    login member
    visit workshop_path workshop
    expect(workshop.attendee? member).to be false
    click_button "Attend as a student"

    expect(page).to have_content("You're coming to Codebar!")
    expect(current_path).to eq(added_workshop_path workshop)
    expect(workshop.attendee? member).to be true
    expect(workshop.attending_students.map(&:member)).to include(member)
    expect(workshop.attending_coaches.map(&:member)).not_to include(member)
  end

  scenario "A logged-in user registering to attend an event doesn't receive an invite email" do
    login member
    visit workshop_path workshop
    expect { click_button "Attend as a student"}.not_to change { ActionMailer::Base.deliveries.count }
  end

  scenario "A logged-in user viewing a future event without student space can join the student waiting list" do
    workshop.host.update_attribute(:seats, 0)
    login member
    visit workshop_path workshop
    expect(workshop.waitlisted? member).to be false
    expect(page).not_to have_button("Attend as a student")
    expect(page).to have_button("Join the student waiting list")

    click_button "Join the student waiting list"
    expect(current_path).to eq(waitlisted_workshop_path workshop)
    expect(workshop.waitlisted? member).to be true
    expect(workshop.attendee? member).to be false
  end

  scenario "A logged-in user viewing a future event with coach space can register to attend" do
    login member
    visit workshop_path workshop
    expect(workshop.attendee? member).to be false
    click_button "Attend as a coach"

    expect(page).to have_content("You're coming to Codebar!")
    expect(current_path).to eq(added_workshop_path workshop)
    expect(workshop.attendee? member).to be true
    expect(workshop.attending_students.map(&:member)).not_to include(member)
    expect(workshop.attending_coaches.map(&:member)).to include(member)
  end

  scenario "A logged-in user viewing a future event without coach space can join the coach waiting list" do
    workshop.host.update_attribute(:seats, 0)
    login member
    visit workshop_path workshop
    expect(workshop.waitlisted? member).to be false
    expect(page).not_to have_button("Attend as a coach")
    expect(page).to have_button("Join the coach waiting list")

    click_button "Join the coach waiting list"
    expect(current_path).to eq(waitlisted_workshop_path workshop)
    expect(workshop.waitlisted? member).to be true
    expect(workshop.attendee? member).to be false
  end

  scenario "A logged-in user signed up on the student attendance list sees they are attending" do
    Fabricate(:student_session_invitation, attending: true, sessions: workshop, member: member)
    expect(workshop.attendee? member).to be true

    login member
    visit workshop_path workshop
    expect(page).not_to have_button("Attend as a student")
    expect(page).not_to have_button("Join the student waiting list")
    expect(page).to have_text("You're attending this event")
    expect(page).to have_button("Cancel your attendance")
  end

  scenario "A logged-in user signed up on the student attendance list can remove themselves from the event" do
    Fabricate(:student_session_invitation, attending: true, sessions: workshop, member: member)
    expect(workshop.attendee? member).to be true
    login member
    visit workshop_path workshop
    click_button "Cancel your attendance"

    expect(current_path).to eq(removed_workshop_path workshop)
    expect(workshop.attendee? member).to be false
    expect(workshop.waitlisted? member).to be false
  end

  scenario "A logged-in user signed up on the coach attendance list sees they are attending" do
    Fabricate(:coach_session_invitation, attending: true, sessions: workshop, member: member)
    expect(workshop.attendee? member).to be true

    login member
    visit workshop_path workshop
    expect(page).not_to have_button("Attend as a coach")
    expect(page).not_to have_button("Join the coach waiting list")
    expect(page).to have_text("You're attending this event")
    expect(page).to have_button("Cancel your attendance")
  end

  scenario "A logged-in user signed up on the coach attendance list can remove themselves from the event" do
    Fabricate(:coach_session_invitation, attending: true, sessions: workshop, member: member)
    expect(workshop.attendee? member).to be true
    login member
    visit workshop_path workshop
    click_button "Cancel your attendance"

    expect(current_path).to eq(removed_workshop_path workshop)
    expect(workshop.attendee? member).to be false
    expect(workshop.waitlisted? member).to be false
  end

  scenario "A logged-in user on the student waiting list sees that they're on the waiting list"
  scenario "A logged-in user on the student waiting list can see their waiting list position"
  scenario "A logged-in user on the student waiting list can remove themself from the waiting list"
  scenario "A logged-in user on the coach waiting list sees that they're on the waiting list"
  scenario "A logged-in user on the coach waiting list can see their waiting list position"
  scenario "A logged-in user on the coach waiting list can remove themself from the waiting list"
end
