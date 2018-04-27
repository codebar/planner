require 'spec_helper'

feature 'member feedback' do
  let(:feedback_request) { Fabricate(:feedback_request) }
  let(:valid_token) { feedback_request.token }
  let(:submited_token) { Fabricate(:feedback_request, submited: true).token }
  let(:invalid_token) { 'feedback_invalid_token' }
  let(:feedback_submited_message) { I18n.t('messages.feedback_saved') }
  let(:coach) { Fabricate(:coach) }

  before do
    Fabricate(:feedback, coach: coach)

    @tutorial = Fabricate(:tutorial, title: 'tutorial title')
    Fabricate(:attended_workshop_invitation, workshop: feedback_request.workshop, member: coach, role: 'Coach')
  end

  context 'Feedback form' do
    scenario 'I can view a feedback form when token is valid' do
      visit feedback_path(valid_token)

      expect(page).to have_select 'feedback_coach_id'
      expect(page).to have_select 'feedback_tutorial_id'
      expect(page).to have_field 'feedback_request'
      expect(page).to have_field 'feedback_suggestions'
      expect(page).to have_selector '//div.rating'
      expect(page).to have_selector '//input[type=submit]'
    end

    scenario 'I can select form coaches list in feedback form' do
      visit feedback_path(valid_token)

      expect(page).to have_select('feedback_coach_id', with_options: [coach.full_name])
    end

    scenario 'I can select form tutorials list in feedback form' do
      visit feedback_path(valid_token)

      expect(page).to have_select('feedback_tutorial_id', with_options: [@tutorial.title])
    end
  end

  context 'I get redirected to the main page' do
    scenario 'when invalid token given' do
      visit feedback_path(invalid_token)

      expect(current_url).to eq(root_url)
      expect(page).to have_content('You have already submitted feedback for this event.')
    end

    scenario 'when feedback has been already submitted' do
      visit feedback_path(submited_token)

      expect(current_url).to eq(root_url)
      expect(page).to have_content('You have already submitted feedback for this event.')
    end
  end

  context 'Submitting a feedback request' do
    scenario 'I can see success page with message and link to homepage when valid data is given' do
      visit feedback_path(valid_token)

      find(:xpath, "//input[@id='feedback_rating']").set '4'
      select(coach.full_name, from: 'feedback_coach_id')
      select(@tutorial.title, from: 'feedback_tutorial_id')

      click_button('Submit feedback')

      expect(current_url).to eq(root_url)

      expect(page).to have_content(feedback_submited_message)
    end
  end
end
