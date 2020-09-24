require 'spec_helper'

RSpec.feature 'Payments', type: :feature do
  context 'a visitor to the website' do
    scenario 'cannot access the payments page' do
      visit new_payment_path

      expect(page).to have_content('You must be logged in to access this page')
    end
  end

  context 'a logged in user' do
    let(:member) { Fabricate(:member) }

    before do
      login(member)
    end

    scenario 'can access the payments page' do
      visit new_payment_path

      expect(page).to have_content('Payments')
    end
  end
end
