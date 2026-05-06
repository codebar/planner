RSpec.feature 'when visiting the coaches page', type: :feature do
  scenario 'I can see the most active coaches' do
    # Use a past workshop date in the current year to ensure the coach is counted
    workshop = Fabricate(:workshop, date_and_time: Time.zone.today.beginning_of_year + 1.month)
    coach = Fabricate(:attended_coach, workshop: workshop).member
    visit coaches_path
    expect(page).to have_content(coach.name, wait: 5)
  end

  scenario 'I can see the top coaches by year' do
    travel_to(Time.current) do
      latest_workshop = Fabricate(:workshop, date_and_time: 1.year.ago)
      old_workshop = Fabricate(:workshop, date_and_time: 3.years.ago)
      2.times { Fabricate(:attended_coach, workshop: latest_workshop) }
      4.times { Fabricate(:attended_coach, workshop: old_workshop) }

      visit coaches_path(year: latest_workshop.date_and_time.year)
      expect(page).to have_css('.coach', count: 2)

      visit coaches_path(year: old_workshop.date_and_time.year)
      expect(page).to have_css('.coach', count: 4)
    end
  end

  scenario 'I can navigate the top coaches by year' do
    travel_to(Time.current) do
      current_workshop = Fabricate(:workshop, date_and_time: Time.current)
      latest_workshop = Fabricate(:workshop, date_and_time: 1.year.ago)
      old_workshop = Fabricate(:workshop, date_and_time: 3.years.ago)
      1.times { Fabricate(:attended_coach, workshop: current_workshop) }
      3.times { Fabricate(:attended_coach, workshop: latest_workshop) }
      2.times { Fabricate(:attended_coach, workshop: old_workshop) }

      visit coaches_path
      expect(page).to have_css('.coach', count: 1)

      click_on latest_workshop.date_and_time.year.to_s
      expect(page).to have_css('.coach', count: 3)

      click_on old_workshop.date_and_time.year.to_s
      expect(page).to have_css('.coach', count: 2)
    end
  end
end
