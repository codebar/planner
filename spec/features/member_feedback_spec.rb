require 'spec_helper'

RSpec.feature 'member feedback', type: :feature do
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

  scenario 'I can display member feedbacks' do
    visit feedback_path(valid_token)

    expect(page).to have_content("Workshop feedback")
    expect(page).to have_content("#{I18n.l(feedback_request.workshop.date_and_time, format: :humanize_date_with_time)}")
  end

  context 'Feedback form' do
    scenario 'I can access the feedback form when the token is valid' do
      visit feedback_path(valid_token)

      expect(page).to have_content('Your submission will be completely anonymous')
      expect(page).to have_content('Please do not mention any names')
      expect(page).to have_select 'feedback_coach_id'
      expect(page).to have_select 'feedback_tutorial_id'
      expect(page).to have_field 'feedback_request'
      expect(page).to have_field 'feedback_suggestions'
      expect(page).to have_selector '//div.rating'
      expect(page).to have_selector '//input[type=submit]'
    end

    scenario 'I can select an entry from the coaches list' do
      visit feedback_path(valid_token)

      expect(page).to have_select('feedback_coach_id', with_options: [coach.full_name])
    end

    scenario 'I can select an entry from tutorials list' do
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

      find(:xpath, "//input[@id='feedback_rating']", visible: false).set '4'
      select(coach.full_name, from: 'feedback_coach_id')
      select(@tutorial.title, from: 'feedback_tutorial_id')

      click_button('Submit feedback')

      expect(current_url).to eq(root_url)

      expect(page).to have_content(feedback_submited_message)
    end

    scenario 'renders an error message when not all mandatory fields have been completed' do
      visit feedback_path(valid_token)

      select(coach.full_name, from: 'feedback_coach_id')
      select(@tutorial.title, from: 'feedback_tutorial_id')

      click_button('Submit feedback')

      expect(page.current_path).to eq(submit_feedback_path(valid_token))
      expect(page).to have_content("Rating can't be blank")
    end
  end
end
