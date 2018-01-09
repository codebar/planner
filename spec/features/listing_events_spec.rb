require 'spec_helper'

feature 'event listing' do
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
      within('.upcoming') do
        expect(page).to have_content upcoming_course.title
        expect(page).to have_content 'Workshop'
        expect(page).to have_content event.name
      end
    end

    scenario 'i can view a list with past events' do
      within('.past') do
        expect(page).to have_content past_course.title
        expect(page).to have_content 'Workshop'
        expect(page).to have_content past_event.name
      end
    end
  end

  context 'when there are more than 40 past events' do
    before(:each) do
      41.times.map { Fabricate(:event, date_and_time: Time.zone.now - 2.weeks) }
      Fabricate(:workshop, date_and_time: Time.zone.now - 3.weeks)
      visit events_path
    end

    scenario 'I can only see 40 past events' do
      within('.past') do
        expect(page).to have_selector('.event', count: 40)
      end
    end

    scenario 'I can\'t see a past event outside of the most recent 40' do
      within('.past') do
        expect(page).not_to have_content 'Workshop'
      end
    end
  end
end
