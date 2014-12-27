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

  scenario "A logged-in user viewing a past event cannot interact with that event" do
    workshop.update_attribute(:date_and_time, 2.weeks.ago)

    login member
    visit workshop_path workshop

    expect(page).not_to have_button("Attend as a student")
    expect(page).not_to have_button("Attend as a coach")
    expect(page).not_to have_button("Join the student waiting list")
    expect(page).not_to have_button("Join the coach waiting list")
    expect(page).to have_content("already happened")
  end

  scenario "A logged-in user who's not attending can attend an imminent event" do
    workshop.update_attribute(:date_and_time, Date.today)
    workshop.update_attribute(:time, 2.hours.from_now)

    login member
    visit workshop_path workshop

    expect(workshop.attendee? member).to be false
    expect(page).to have_button("Attend as a student")
    expect(page).to have_button("Attend as a coach")

    click_button "Attend as a student"
    expect(workshop.attendee? member).to be true
    expect(page).to have_content("You're coming to Codebar!")
    expect(current_path).to eq(added_workshop_path workshop)
  end

  scenario "A logged-in user who's attending an imminent event cannot interact with that event" do
    workshop.update_attribute(:date_and_time, Date.today)
    workshop.update_attribute(:time, 2.hours.from_now)
    Fabricate(:student_session_invitation, attending: true, sessions: workshop, member: member)
    expect(workshop.attendee? member).to be true

    login member
    visit workshop_path workshop

    expect(page).not_to have_button("Attend as a student")
    expect(page).not_to have_button("Attend as a coach")
    expect(page).to have_content "If you can no longer make it, email us"
  end

  scenario "A logged-in user on the waiting list can remove themselves from the waiting list for an imminent event" do
    workshop.update_attribute(:date_and_time, Date.today)
    workshop.update_attribute(:time, 2.hours.from_now)
    invite = Fabricate(:student_session_invitation, sessions: workshop, member: member)
    WaitingList.add(invite)

    login member
    visit workshop_path workshop

    expect(workshop.waitlisted? member).to be true

    click_button "Leave the waiting list"
    expect(current_path).to eq(removed_workshop_path workshop)
    expect(workshop.waitlisted? member).to be false
  end


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

  scenario "A logged-in user on the student waiting list sees that they're on the waiting list" do
    invite = Fabricate(:student_session_invitation, sessions: workshop, member: member)
    WaitingList.add(invite)
    expect(workshop.attendee? member).to be false
    expect(workshop.waitlisted? member).to be true

    login member
    visit workshop_path workshop
    expect(page).to have_content("You're on the waiting list")
    expect(page).to have_button("Leave the waiting list")
  end

  scenario "A logged-in user on the student waiting list can remove themself from the waiting list" do
    invite = Fabricate(:student_session_invitation, sessions: workshop, member: member)
    WaitingList.add(invite)
    expect(workshop.waitlisted? member).to be true

    login member
    visit workshop_path workshop
    click_button "Leave the waiting list"
    expect(current_path).to eq(removed_workshop_path workshop)
    expect(workshop.waitlisted? member).to be false
  end

  scenario "A logged-in user on the coach waiting list sees that they're on the waiting list" do
    invite = Fabricate(:coach_session_invitation, sessions: workshop, member: member)
    WaitingList.add(invite)
    expect(workshop.attendee? member).to be false
    expect(workshop.waitlisted? member).to be true

    login member
    visit workshop_path workshop
    expect(page).to have_content("You're on the waiting list")
    expect(page).to have_button("Leave the waiting list")
  end

  scenario "A logged-in user on the coach waiting list can remove themself from the waiting list" do
    invite = Fabricate(:coach_session_invitation, sessions: workshop, member: member)
    WaitingList.add(invite)
    expect(workshop.waitlisted? member).to be true

    login member
    visit workshop_path workshop
    click_button "Leave the waiting list"
    expect(current_path).to eq(removed_workshop_path workshop)
    expect(workshop.waitlisted? member).to be false
  end

  scenario "A user with both coach and student invites, waitlisted as a student, sees the student messaging on the waitlisted page" do
    invite = Fabricate(:student_session_invitation, sessions: workshop, member: member)
    Fabricate(:coach_session_invitation, sessions: workshop, member: member)
    WaitingList.add(invite)

    login member
    visit waitlisted_workshop_path workshop
    expect(page).not_to have_content("As a coach")
    expect(page).to have_content("As a student")
  end

  scenario "A user with both coach and student invites, waitlisted as a coach, sees the coach messaging on the waitlisted page" do
    Fabricate(:student_session_invitation, sessions: workshop, member: member)
    invite = Fabricate(:coach_session_invitation, sessions: workshop, member: member)
    WaitingList.add(invite)

    login member
    visit waitlisted_workshop_path workshop
    expect(page).to have_content("As a coach")
    expect(page).not_to have_content("As a student")
  end
end
