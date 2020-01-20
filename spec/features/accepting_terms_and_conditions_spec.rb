require 'spec_helper'

RSpec.feature 'Accepting Terms and Conditions', type: :feature, wip: true do
  before do
    mock_github_auth
  end

  context 'When a user signs up to codebar' do
    scenario 'they can''t proceed unless they accept the ToCs' do
      visit root_path
      click_on 'Sign up as a student'
      click_on 'I understand and meet the eligibility criteria. Sign me up as a student'

      expect(page).to have_current_path(terms_and_conditions_path)

      click_on 'Accept'
      expect(page).to have_current_path(terms_and_conditions_path)
      expect(page).to have_content('You have to accept the Terms and Conditions before you are able to proceed.')
    end

    scenario 'they can fill in their details after they accept the ToCs' do
      visit root_path
      click_on 'Sign up as a student'
      click_on 'I understand and meet the eligibility criteria. Sign me up as a student'

      expect(page).to have_current_path(terms_and_conditions_path)

      check I18n.t('members.terms_and_conditions.agree')
      click_on 'Accept'

      expect(page).to have_current_path(step1_member_path(member_type: 'student'))
    end
  end

  context 'When an existing member logs in' do
    context 'and they have not yet accepted codebar''s ToCs' do
      scenario 'they have to accept before proceeding' do
        pending
      end
    end

    context 'and they have already accepted codebar''s ToCs' do
      scenario 'they will be redirected to the link they were trying to access' do
        pending
      end
    end
  end
end
