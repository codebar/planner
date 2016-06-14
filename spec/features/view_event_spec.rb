require 'spec_helper'

feature 'viewing an event' do
  let(:closed_event) { Fabricate(:event, confirmation_required: true, surveys_required: true) }
  let(:open_event) { Fabricate(:event, confirmation_required: false, surveys_required: false) }

  context 'that requires a survey and verification of spot' do
    before do
      visit event_path(closed_event)
    end

    context "a non authenticated user" do
      scenario 'a user can view an event' do
        expect(page).to have_content(closed_event.name)
        expect(page).to have_content(closed_event.description)
        expect(page).to have_content(closed_event.schedule)
      end

      scenario 'a student cannot RSVP if they are not logged in' do
        click_on 'Attend as a student'

        expect(page).to have_content(I18n.t('notifications.not_logged_in'))
      end

      scenario 'a student cannot RSVP if they are not logged in' do
        click_on 'Attend as a coach'

        expect(page).to have_content(I18n.t('notifications.not_logged_in'))
      end
    end

    context "an authenticated user" do
      let(:member) { Fabricate(:member) }

      before do
        login(member)
      end

      context 'can RSVP to an event' do

        scenario "as a Coach" do
          click_on 'Attend as a coach'
          click_on 'RSVP'

          expect(page).to have_content("Your spot has been confirmed for #{closed_event.name}! We look forward to seeing you there. We will verify your attendance after you complete the questionnaire!")
        end

        scenario "as a Student" do
          click_on 'Attend as a student'
          click_on 'RSVP'

          expect(page).to have_content("Your spot has been confirmed for #{closed_event.name}! We look forward to seeing you there. We will verify your attendance after you complete the questionnaire!")
        end
      end
    end
  end

  context 'that does not require survey or spot verification' do
    before do
      visit event_path(open_event)
    end

    context "an authenticated user" do
      let(:member) { Fabricate(:member) }

      before do
        login(member)
      end

      context 'can RSVP to an event' do

        scenario "as a Coach" do
          click_on 'Attend as a coach'
          click_on 'RSVP'

          expect(page).to have_content("Your spot has been confirmed for #{open_event.name}! We look forward to seeing you there")
          expect(page).not_to have_content("We will verify your attendance after you complete the questionnaire!")
        end

        scenario "as a Student" do
          click_on 'Attend as a student'
          click_on 'RSVP'

          expect(page).to have_content("Your spot has been confirmed for #{open_event.name}! We look forward to seeing you there")
          expect(page).not_to have_content("We will verify your attendance after you complete the questionnaire!")
        end
      end
    end
  end
end
