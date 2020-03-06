require 'spec_helper'

RSpec.feature 'viewing a meeting', type: :feature do
  let!(:meeting) { Fabricate(:meeting) }

  context 'a visitor' do
    before(:each) do
      visit meeting_path(meeting)
    end

    scenario 'can view the page title' do
      expect(page).to have_title("#{meeting.name} - #{humanize_date(meeting.date_and_time)}")
    end

    scenario "can view a meeting's information" do

      expect(page).to have_content meeting.name
      expect(page).to have_content meeting.venue.name
    end
  end
end
