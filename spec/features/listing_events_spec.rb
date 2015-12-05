require 'spec_helper'

feature 'event listing' do

  let!(:upcoming_course) { Fabricate(:course) }
  let!(:past_course) { Fabricate(:course, chapter: upcoming_course.chapter, date_and_time: Time.zone.now-1.week) }
  let!(:upcoming_session) { Fabricate(:sessions) }
  let!(:past_session) { Fabricate(:sessions, date_and_time: Time.zone.now-1.week) }
  let!(:event) { Fabricate(:event) }
  let!(:past_event) { Fabricate(:event, date_and_time: Time.zone.now-2.weeks) }

  before do
    visit events_path
  end

  scenario 'i can view a list with upcoming events' do

    within(".upcoming") do
      expect(page).to have_content upcoming_course.title
      expect(page).to have_content "Workshop"
      expect(page).to have_content event.name
    end
  end

  scenario 'i can view a list with past events' do

    within(".past") do
      expect(page).to have_content past_course.title
      expect(page).to have_content "Workshop"
      expect(page).to have_content past_event.name
    end
  end
end
