require 'spec_helper'

RSpec.feature 'when visiting the coaches page', type: :feature do
  scenario 'I can see the most active coaches' do
    coach = Fabricate(:attended_coach).member
    visit coaches_path
    expect(page).to have_content coach.name
  end

  scenario 'I can see the top coaches by year' do
    latest_workshop = Fabricate(:workshop, date_and_time: Time.zone.now - 1.year)
    old_workshop = Fabricate(:workshop, date_and_time: Time.zone.now - 3.years)
    invitations = 5.times { Fabricate(:attended_coach, workshop: latest_workshop) }
    older_invitations = 15.times { Fabricate(:attended_coach, workshop: old_workshop) }

    visit coaches_path(year: latest_workshop.date_and_time.year)
    expect(page).to have_css(".coach", count: 5)

    visit coaches_path(year: old_workshop.date_and_time.year)
    expect(page).to have_css(".coach", count: 15)
  end

  scenario 'I can navigate the top coaches by year' do
    current_workshop = Fabricate(:workshop, date_and_time: Time.zone.now)
    latest_workshop = Fabricate(:workshop, date_and_time: Time.zone.now - 1.year)
    old_workshop = Fabricate(:workshop, date_and_time: Time.zone.now - 3.years)
    current_invitations = 10.times { Fabricate(:attended_coach, workshop: current_workshop) }
    invitations = 7.times { Fabricate(:attended_coach, workshop: latest_workshop) }
    older_invitations = 12.times { Fabricate(:attended_coach, workshop: old_workshop) }

    visit coaches_path
    expect(page).to have_css(".coach", count: 10)

    click_on latest_workshop.date_and_time.year.to_s
    expect(page).to have_css(".coach", count: 7)

    click_on old_workshop.date_and_time.year.to_s
    expect(page).to have_css(".coach", count: 12)
  end
end
