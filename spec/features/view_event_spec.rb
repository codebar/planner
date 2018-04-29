require 'spec_helper'

feature 'viewing an event' do
  let(:closed_event) { Fabricate(:event, confirmation_required: true, surveys_required: true) }
  let(:open_event) { Fabricate(:event, confirmation_required: false, surveys_required: false) }

  context 'that requires a survey and verification of spot' do
    before do
      visit event_path(closed_event)
    end

    context 'a non authenticated user' do
      scenario 'a user can view an event' do
        expect(page).to have_content(closed_event.name)
        expect(page).to have_content(closed_event.description)
        expect(page).to have_content(closed_event.schedule)
      end

      scenario 'a student cannot RSVP if they are not logged in' do
        expect(page).to have_link('Log in')
        expect(page).to have_link('Sign up')
        expect(page).to_not have_link('Attend as a student')
      end

      scenario 'a coach cannot RSVP if they are not logged in' do
        expect(page).to have_link('Log in')
        expect(page).to have_link('Sign up')
        expect(page).to_not have_link('Attend as a coach')
      end
    end

    context 'an authenticated user' do
      let(:member) { Fabricate(:member) }

      before do
        login_mock_omniauth(member, 'Log in')
      end

      context 'can RSVP to an event' do
        scenario 'as a Coach' do
          expect(current_path).to eq(event_path(closed_event))

          click_on 'Attend as a coach'
          click_on 'RSVP'

          expect(page).to have_content('Your spot has not yet been confirmed. We will verify your attendance after you complete the questionnaire.')
        end

        scenario 'as a Student' do
          expect(current_path).to eq(event_path(closed_event))

          click_on 'Attend as a student'
          click_on 'RSVP'

          expect(page).to have_content('Your spot has not yet been confirmed. We will verify your attendance after you complete the questionnaire.')
        end
      end
    end
  end

  context 'that does not require survey or spot verification' do
    before do
      visit event_path(open_event)
    end

    context 'an authenticated user' do
      let(:member) { Fabricate(:member) }

      before do
        login_mock_omniauth(member, 'Log in')
      end

      context 'can RSVP to an event' do
        scenario 'as a Coach' do
          expect(current_path).to eq(event_path(open_event))

          click_on 'Attend as a coach'
          click_on 'RSVP'

          expect(page).to have_content("Your spot has been confirmed for #{open_event.name}! We look forward to seeing you there")
          expect(page).not_to have_content('We will verify your attendance after you complete the questionnaire!')
        end

        scenario 'as a Student' do
          expect(current_path).to eq(event_path(open_event))

          click_on 'Attend as a student'
          click_on 'RSVP'

          expect(page).to have_content("Your spot has been confirmed for #{open_event.name}! We look forward to seeing you there")
          expect(page).not_to have_content('We will verify your attendance after you complete the questionnaire!')
        end
      end

      scenario 'is redirected to the event invitation page if they have RSVPed' do
        invitation = Fabricate(:attending_event_invitation, event: open_event, member: member)
        visit event_path(open_event)

        expect(current_path).to eq(event_invitation_path(open_event, invitation.token))
      end
    end
  end
end
