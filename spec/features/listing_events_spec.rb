require 'spec_helper'
require 'events_controller'

RSpec.feature 'event listing', type: :feature do
  describe 'I can see the names and titles of events' do
    let!(:upcoming_course) { Fabricate(:course) }
    let!(:upcoming_workshop) { Fabricate(:workshop) }
    let!(:event) { Fabricate(:event) }
    let!(:past_course) { Fabricate(:course, chapter: upcoming_course.chapter, date_and_time: Time.zone.now - 1.week) }
    let!(:past_event) { Fabricate(:event, date_and_time: Time.zone.now - 2.weeks) }
    let!(:past_workshop) { Fabricate(:workshop, date_and_time: Time.zone.now - 1.week) }

    before do
      visit events_path
    end

    scenario 'i can view a list with upcoming events' do
      within('*[data-test=upcoming-events]') do
        expect(page).to have_content upcoming_course.title
        expect(page).to have_content 'Workshop'
        expect(page).to have_content event.name
      end
    end

    scenario 'i can view a list with past events' do
      within('*[data-test=past-events]') do
        expect(page).to have_content past_course.title
        expect(page).to have_content 'Workshop'
        expect(page).to have_content past_event.name
      end
    end
  end

  context 'when there are more than the specified number of past events' do
    scenario 'I can only as many events allowed by the display limits' do
      Fabricate.times(10, :event, date_and_time: 2.weeks.ago)
      stub_const('EventsController::RECENT_EVENTS_DISPLAY_LIMIT', 10)
      Fabricate(:workshop, date_and_time: 3.weeks.ago)

      visit events_path
      within('*[data-test=past-events]') do
        expect(page).to have_selector('.event', count: 11)
        expect(page).not_to have_content 'Workshop'
      end
    end
  end
end
