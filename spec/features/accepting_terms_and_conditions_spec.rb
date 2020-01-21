require 'spec_helper'

RSpec.feature 'Accepting Terms and Conditions', type: :feature do

  context 'When a user signs up to codebar' do
    before do
      mock_github_auth
    end

    scenario 'they can''t proceed unless they accept the ToCs' do
      visit root_path
      click_on 'Sign up as a student'
      click_on 'I understand and meet the eligibility criteria. Sign me up as a student'

      expect(page).to have_current_path(terms_and_conditions_path)

      click_on 'Accept'
      expect(page).to have_current_path(terms_and_conditions_path)
      expect(page).to have_content('You have to accept the Terms and Conditions before you are able to proceed.')
    end

    scenario 'they can read the Code of Conduct before accepting the ToCs', js: true do
      visit root_path
      click_on 'Sign up as a student'
      click_on 'I understand and meet the eligibility criteria. Sign me up as a student'

      expect(page).to have_current_path(terms_and_conditions_path)

      click_on I18n.t('terms_and_conditions.link_text')
      page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)

      expect(page).to have_content(I18n.t('code_of_conduct.title'))
      expect(page).to have_content(I18n.t('code_of_conduct.summary.title'))
      expect(page).to have_content(I18n.t('code_of_conduct.content.title'))
    end

    scenario 'they can fill in their details after they accept the ToCs' do
      visit root_path
      click_on 'Sign up as a student'
      click_on 'I understand and meet the eligibility criteria. Sign me up as a student'

      expect(page).to have_current_path(terms_and_conditions_path)

      check :terms
      click_on 'Accept'

      expect(page).to have_current_path(step1_member_path(member_type: 'student'))
    end
  end

  context 'When an existing member logs in' do

    context 'and they have not yet accepted codebar''s ToCs' do
      scenario 'they have to accept before continuing to the page they want to get' do
        member = Fabricate(:member_without_toc)
        login(member)
        visit root_path
        expect(page).to have_current_path(terms_and_conditions_path)

        accept_toc
        expect(page).to have_current_path(root_path)
      end
    end

    context 'and they have already accepted codebar''s ToCs' do
      scenario 'they will be redirected to the link they were trying to access' do
        member = Fabricate(:member)
        login(member)

        visit dashboard_path
        expect(page).to have_current_path(dashboard_path)
      end
    end
  end
end
