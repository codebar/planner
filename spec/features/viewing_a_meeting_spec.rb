require 'spec_helper'

feature 'viewing a meeeting' do

  let!(:meeting) { create_meeting }

  scenario "i can view a meeting's information" do
    meeting_talk = meeting.meeting_talks.first
    visit meeting_path(meeting)

    expect(page).to have_content meeting.title

    expect(page).to have_content meeting_talk.speaker.name
    expect(page).to have_content meeting_talk.title
    expect(page).to have_content meeting_talk.description
    expect(page).to have_content meeting_talk.abstract

    expect(page).to have_content "read our code of conduct"
    expect(page).to have_link "Sign up for the meeting", href: meeting.lanyrd_url
  end
end

def create_meeting
  meeting = Meeting.create(venue: Fabricate(:sponsor),
                           date_and_time: DateTime.now+1.year-11.months,
                           duration: 120,
                           lanyrd_url: "http://lanyrd.com/2013/by-codebar/")
  meeting.meeting_talks << MeetingTalk.create(title: "Becoming a Software Engineer",
                                               description: "Inspiring a New Generation of Developers",
                                               speaker: Fabricate(:member),
                                               abstract: Faker::Lorem.paragraph)
  meeting
end

