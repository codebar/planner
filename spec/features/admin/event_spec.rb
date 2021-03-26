require 'spec_helper'

RSpec.feature 'Event creation', type: :feature do
  let(:member) { Fabricate(:member) }
  let(:chapter) { Fabricate(:chapter_with_groups) }

  describe 'an authorised member' do
    before do
      member.add_role(:organiser, chapter)
      login_as_admin(member)
    end

    describe 'can successfully create an event' do
      scenario 'when they fill in all mandatory fields' do
        sponsor = Fabricate(:sponsor)
        date = Time.zone.today + 2.days
        visit new_admin_event_path

        fill_in 'Event Name', with: 'A test event'
        fill_in 'Slug', with: 'a-test-event'
        fill_in 'Date', with: date
        fill_in 'Begins at', with: '16:00'
        fill_in 'Ends at', with: '18:00'
        fill_in 'Description', with: 'A test event description'
        fill_in 'RSVP instructions', with: 'Some instructions'
        fill_in 'Schedule', with: '9:00 Sign up & breakfast <br/> 9:30 kick off'
        fill_in 'Coach spaces', with: '19'
        fill_in 'Student spaces', with: '25'
        select sponsor.name, from: 'Venue'
        click_on 'Save'

        expect(page).to have_content('Event successfully created')

        expect(page).to have_content('A test event')
        expect(page).to have_content(humanize_date(date))
        expect(page).to have_content('A test event description')
        expect(page).to have_content('25 student spots, 19 coach spots')
        expect(find('#schedule', visible: false).text).to eq('9:00 Sign up & breakfast 9:30 kick off')

        within '#host' do
          expect(page).to have_content sponsor.name
          expect(page).to have_content sponsor.address.street
          expect(page).to have_content sponsor.address.city
        end
      end
    end

    describe 'can not create an event' do
      scenario 'when they don\'t fill in any of the events details' do
        visit new_admin_event_path

        click_on 'Save'

        expect(page).to have_content('Make sure you fill in all mandatory fields')
      end
    end
  end
end
