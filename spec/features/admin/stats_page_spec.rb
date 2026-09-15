require 'rails_helper'

RSpec.feature 'admin stats page' do
  let(:member) { Fabricate(:member) }

  before do
    login_as_admin(member)
  end

  scenario 'the portal links to the stats page and the default view covers the most recent 3 complete months' do # rubocop:disable RSpec/MultipleExpectations
    Fabricate(:workshop_no_sponsor, date_and_time: Time.zone.local(2026, 8, 1, 18, 30))

    travel_to(Time.zone.local(2026, 9, 10, 12, 0)) do
      visit admin_root_path

      expect(page).to have_link('Stats', href: admin_stats_path)
      click_link('Stats', href: admin_stats_path)

      expect(page).to have_css('caption', text: 'Attendance')
      expect(page).to have_css('caption', text: 'New sign-ups')
      expect(page).to have_css('caption', text: 'Workshops')
      expect(page).to have_css('th', text: 'August 2026')
      expect(page).to have_no_selector('th', text: 'September 2026')
      expect(page).to have_no_selector('th', text: 'May 2026')
      expect(page).to have_css('.btn-outline-primary.active', text: '3 months')
      expect(page).to have_link('Download CSV')
    end
  end

  scenario 'the 3-month preset re-renders the last three complete months' do
    Fabricate(:workshop_no_sponsor, date_and_time: Time.zone.local(2026, 6, 1, 18, 30))

    travel_to(Time.zone.local(2026, 9, 10, 12, 0)) do
      visit admin_stats_path

      click_button '3 months'

      expect(page).to have_css('th', text: 'June 2026')
      expect(page).to have_css('th', text: 'July 2026')
      expect(page).to have_css('th', text: 'August 2026')
      expect(page).to have_no_selector('th', text: 'May 2026')
    end
  end

  scenario 'a single-month custom range renders one month column with sign-up roles' do
    june_member = Fabricate(:member, created_at: Time.zone.local(2026, 6, 10, 14, 0))
    Fabricate(:subscription, member: june_member, group: Fabricate(:coaches))

    travel_to(Time.zone.local(2026, 9, 10, 12, 0)) do
      visit admin_stats_path(stats: { start_month: '2026-06', end_month: '2026-06' })

      expect(page).to have_css('th', text: 'June 2026')
      expect(page).to have_no_selector('th', text: 'May 2026')
      expect(page).to have_no_selector('th', text: 'July 2026')

      expect(find('tr', text: 'New coaches')).to have_text('1')
      expect(find('tr', text: 'New students')).to have_text('0')
      expect(find('tr', text: 'Total new members')).to have_text('1')

      expect(page).to have_link('Download CSV',
                                href: admin_stats_path(stats: { start_month: '2026-06', end_month: '2026-06' },
                                                       format: :csv))
    end
  end

  scenario 'a dual-group member counts once in the total and in both role rows' do
    july_member = Fabricate(:member, created_at: Time.zone.local(2026, 7, 5, 9, 0))
    Fabricate(:subscription, member: july_member, group: Fabricate(:coaches))
    Fabricate(:subscription, member: july_member, group: Fabricate(:students))

    travel_to(Time.zone.local(2026, 9, 10, 12, 0)) do
      visit admin_stats_path(stats: { start_month: '2026-07', end_month: '2026-07' })

      expect(find('tr', text: 'New students')).to have_text('1')
      expect(find('tr', text: 'New coaches')).to have_text('1')
      expect(find('tr', text: 'Total new members')).to have_text('1')
    end
  end

  scenario 'a start-after-end submission shows the inline error and keeps the previous range' do
    Fabricate(:workshop_no_sponsor, date_and_time: Time.zone.local(2026, 6, 1, 18, 30))

    travel_to(Time.zone.local(2026, 9, 10, 12, 0)) do
      visit admin_stats_path
      click_button '3 months'

      fill_in 'Start month', with: '2026-08'
      fill_in 'End month', with: '2026-07'
      click_button 'Apply'

      expect(page).to have_text('The start month must not be after the end month.')
      expect(page).to have_css('th', text: 'June 2026')
      expect(page).to have_css('th', text: 'July 2026')
      expect(page).to have_css('th', text: 'August 2026')
    end
  end

  scenario 'row totals equal the sum of the month cells' do
    may = Fabricate(:workshop_no_sponsor, date_and_time: Time.zone.local(2026, 5, 6, 18, 30))
    june = Fabricate(:workshop_no_sponsor, date_and_time: Time.zone.local(2026, 6, 10, 18, 30))
    coach = Fabricate(:member)
    Fabricate(:attended_workshop_invitation, workshop: may, member: coach, role: 'Coach')
    Fabricate(:attended_workshop_invitation, workshop: june, member: coach, role: 'Coach')
    Fabricate(:attended_workshop_invitation, workshop: june, role: 'Coach')

    travel_to(Time.zone.local(2026, 9, 10, 12, 0)) do
      visit admin_stats_path(stats: { start_month: '2026-05', end_month: '2026-06' })

      row = find('tr', text: 'Coach check-ins')
      expect(row.all('td').map(&:text)).to eq(%w[1 2 3])
    end
  end
end
