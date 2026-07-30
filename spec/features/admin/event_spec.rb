RSpec.feature 'Event creation', type: :feature do
  let(:member) { Fabricate(:member) }
  let(:chapter) { Fabricate(:chapter) }

  def fill_in_mandatory_event_fields(name:, slug:, description:, date:, sponsor:)
    fill_in 'Event Name', with: name
    fill_in 'Slug', with: slug
    fill_in 'Date', with: date
    fill_in 'Starts at', with: '16:00'
    fill_in 'Ends at', with: '18:00'
    fill_in 'Description', with: description
    fill_in 'RSVP instructions', with: 'Some instructions'
    fill_in 'Schedule', with: '9:00 Sign up & breakfast <br/> 9:30 kick off'
    fill_in 'Coach spaces', with: '19'
    fill_in 'Student spaces', with: '25'
    select sponsor.name, from: 'Venue'
    click_on 'Save'
  end

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

        fill_in_mandatory_event_fields(name: 'A test event', slug: 'a-test-event',
                                       description: 'A test event description', date: date, sponsor: sponsor)

        aggregate_failures do
          expect(page).to have_text('Event successfully created')
          expect(page).to have_text('A test event')
          expect(page).to have_text(humanize_date(date))
          expect(page).to have_text('A test event description')
          expect(page).to have_text('25 student spots, 19 coach spots')
          expect(page).to have_text('9:00 Sign up & breakfast 9:30 kick off')

          within '#host' do
            expect(page).to have_text sponsor.name
            expect(page).to have_text sponsor.address.street
            expect(page).to have_text sponsor.address.city
          end
        end
      end
    end

    describe 'can successfully create a virtual event' do
      scenario 'when they fill in all mandatory fields' do
        Fabricate(:sponsor)
        date = Time.zone.today + 2.days
        visit new_admin_event_path

        fill_in 'Event Name', with: 'A test virtual event'
        fill_in 'Slug', with: 'a-test-virtual-event'
        fill_in 'Date', with: date
        fill_in 'Starts at', with: '16:00'
        fill_in 'Ends at', with: '18:00'
        fill_in 'Description', with: 'A test virtual event description'
        fill_in 'RSVP instructions', with: 'Some instructions'
        fill_in 'Schedule', with: '9:00 Sign up & breakfast <br/> 9:30 kick off'
        fill_in 'Coach spaces', with: '19'
        fill_in 'Student spaces', with: '25'
        check 'This is a virtual event'
        click_on 'Save'

        expect(page).to have_text('Event successfully created')

        expect(page).to have_text('A test virtual event')
        expect(page).to have_text(humanize_date(date))
        expect(page).to have_text('A test virtual event description')
        expect(page).to have_text('25 student spots, 19 coach spots')
        expect(page).to have_text('9:00 Sign up & breakfast 9:30 kick off')

        within '#host' do
          expect(page).to have_text('This is a virtual event.')
        end
      end
    end

    describe 'can not create an event' do
      scenario 'when they don\'t fill in any of the events details' do
        visit new_admin_event_path

        click_on 'Save'

        expect(page).to have_text('Make sure you fill in all mandatory fields')
      end
    end
  end
end
