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

  context 'an authenticated user' do
    let(:member) { Fabricate(:member) }

    scenario 'can toggle attendance' do
      visit meeting_path(meeting)
      login_mock_omniauth(member, 'Log in')

      click_on 'RSVP here'

      expect(page).to have_content('Your RSVP was successful. We look forward to seeing you at the Monthly!')

      click_on "Can't make it anymore? Click here to cancel your spot"

      expect(page).to have_content("Thanks for letting us know you can't make it")
    end
  end
end
