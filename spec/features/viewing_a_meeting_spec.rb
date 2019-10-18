require 'spec_helper'

RSpec.feature 'viewing a meeting', type: :feature do
  let!(:meeting) { Fabricate(:meeting) }

  scenario "i can view a meeting's information" do
    visit meeting_path(meeting)

    expect(page).to have_content meeting.name
    expect(page).to have_content meeting.venue.name
  end
end
