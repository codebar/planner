require 'spec_helper'

feature 'viewing a meeting' do
  let!(:meeting) { create_meeting }

  scenario "i can view a meeting's information" do
    visit meeting_path(meeting)

    expect(page).to have_content meeting.name
    expect(page).to have_content meeting.venue.name
  end
end

def create_meeting
  Meeting.create(venue: Fabricate(:sponsor),
                 name: 'codebar Monthly - March',
                 date_and_time: Time.zone.now + 1.year - 11.months,
                 spaces: 10,
                 description: 'Join us for an evening of talks')
end
