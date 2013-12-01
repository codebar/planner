require 'spec_helper'

feature 'session listing' do

  let!(:upcoming_session) { Fabricate(:sessions) }
  let!(:past_session) { Fabricate(:sessions, date_and_time: DateTime.new-1.week) }

  before do
    visit sessions_path
  end

  scenario 'i can view a list with upcoming sessions' do

    expect(page).to have_content "Upcoming sessions"
    expect(page).to have_content upcoming_session.title
    expect(page).to have_content upcoming_session.description
  end

  scenario 'i can view a list with past sessions' do

    expect(page).to have_content "Past sessions"
    expect(page).to have_content past_session.title
    expect(page).to have_content past_session.description
  end
end
