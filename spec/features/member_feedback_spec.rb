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
      expect(page).to have_button 'Submit feedback'
    end

    scenario 'I can select an entry from the coaches list' do
      visit feedback_path(valid_token)

      expect(page).to have_select('feedback_coach_id', with_options: [coach.full_name])
    end

    scenario 'I can select an entry from tutorials list' do
      visit feedback_path(valid_token)

      expect(page).to have_select('feedback_tutorial_id', with_options: [@tutorial.title])
    end

    scenario 'I can see coaches who RSVPd but have not yet been marked as attended (Issue #2367)' do
      # This reproduces the real-world scenario where:
      # 1. Coach RSVPs to workshop (attending = true)
      # 2. Feedback is sent the next day
      # 3. Organizer hasn't yet marked attendance (attended = nil)
      coach_not_yet_verified = Fabricate(:coach)
      Fabricate(:attending_workshop_invitation,
        workshop: feedback_request.workshop,
        member: coach_not_yet_verified,
        role: 'Coach',
        attended: nil)

      visit feedback_path(valid_token)

      # Coach should appear in the list even though attended is nil
      expect(page).to have_select('feedback_coach_id', with_options: [coach_not_yet_verified.full_name])
    end

    scenario 'verified coaches appear before unverified coaches in the list' do
      # Create two coaches: one verified (attended=true), one not yet (attended=nil)
      verified_coach = Fabricate(:coach, name: 'Alice', surname: 'Verified')
      unverified_coach = Fabricate(:coach, name: 'Bob', surname: 'Unverified')

      Fabricate(:attended_workshop_invitation,
        workshop: feedback_request.workshop,
        member: verified_coach,
        role: 'Coach')

      Fabricate(:attending_workshop_invitation,
        workshop: feedback_request.workshop,
        member: unverified_coach,
        role: 'Coach',
        attended: nil)

      visit feedback_path(valid_token)

      # Get all coach options in order
      select_options = page.find('#feedback_coach_id').all('option').map(&:text).reject(&:blank?)
      verified_index = select_options.index(verified_coach.full_name)
      unverified_index = select_options.index(unverified_coach.full_name)

      # Verified coach should appear before unverified coach
      expect(verified_index).to be < unverified_index
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
    scenario 'I can see success page with message and link to homepage when valid data is given', js: true do
      visit feedback_path(valid_token)

      # Wait for Chosen dropdowns to initialize
      expect(page).to have_css('#feedback_coach_id_chosen')
      expect(page).to have_css('#feedback_tutorial_id_chosen')

      within('.rating') { all('li').at(3).click }
      select_from_chosen(coach.full_name, from: 'feedback_coach_id')
      select_from_chosen(@tutorial.title, from: 'feedback_tutorial_id')
      click_button('Submit feedback')

      expect(page).to have_current_path(root_path)

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
