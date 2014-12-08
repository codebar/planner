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
  scenario "A logged-in user viewing a future event with student space can register to attend"
  scenario "A logged-in user viewing a future event without student space can join the student waiting list"
  scenario "A logged-in user viewing a future event with coach space can register to attend"
  scenario "A logged-in user viewing a future event without coach space can join the coach waiting list"
  scenario "A logged-in user signed up on the student attendance list sees they are attending"
  scenario "A logged-in user signed up on the student attendance list can remove themselves from the event"
  scenario "A logged-in user signed up on the coach attendance list sees they are attending"
  scenario "A logged-in user signed up on the coach attendance list can remove themselves from the event"
  scenario "A logged-in user on the student waiting list sees that they're on the waiting list"
  scenario "A logged-in user on the student waiting list can see their waiting list position"
  scenario "A logged-in user on the student waiting list can remove themself from the waiting list"
  scenario "A logged-in user on the coach waiting list sees that they're on the waiting list"
  scenario "A logged-in user on the coach waiting list can see their waiting list position"
  scenario "A logged-in user on the coach waiting list can remove themself from the waiting list"
end
