require 'spec_helper'

feature 'event listing' do

  let!(:upcoming_workshop) { Fabricate(:workshop) }
  let!(:past_workshop) { Fabricate(:workshop, date_and_time: Time.zone.now-1.week) }
  let!(:event) { Fabricate(:event) }
  let!(:past_event) { Fabricate(:event, date_and_time: Time.zone.now-2.weeks) }

  before { visit events_path }

  scenario 'I can view a list with upcoming and past events' do
    within(".upcoming") do
      expect(page).to have_content upcoming_workshop.host.name
      expect(page).to have_content upcoming_workshop.to_s
      expect(page).to have_content event.name
    end

    within(".past") do
      expect(page).to have_content past_workshop.host.name
      expect(page).to have_content past_workshop.to_s
      expect(page).to have_content past_event.name
    end
  end
end
