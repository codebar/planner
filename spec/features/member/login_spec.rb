require 'spec_helper'

RSpec.feature 'Member logging in', type: :feature do
  let(:member) { Fabricate(:member) }

  describe 'Sign up' do
    describe 'when not all required details are set' do
      it 'handles the registration when a user does not have a name set on github' do
        mock_auth_hash(name: nil)

        visit root_path
        click_link 'Sign in'

        check 'terms_and_conditions_form_terms'
        click_on 'Accept'

        expect(page).to have_content('Almost there...')
      end
    end

    it 'registers a user that does not have an account' do
      mock_auth_hash
      visit root_path
      expect{
        click_link 'Sign in'
      }.to change{ Member.count }.by(1)
    end
  end
end
