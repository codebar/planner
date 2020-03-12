require 'spec_helper'
RSpec.feature 'Viewing a workshop page', type: :feature do
  context 'visitor' do
    before(:each) do
      visit workshop_path(workshop)
    end

    let(:workshop) { Fabricate(:workshop) }

    scenario 'can view a workshop' do
      expect(page).to be
    end

    scenario 'can view the page title' do
      expect(page).to have_title("Workshop at #{workshop.host.name} - #{humanize_date(workshop.date_and_time)}")
    end

    scenario 'can sign up or sign in' do
      expect(page).to have_content('Sign up')
      expect(page).to have_content('Log in')
    end
  end
end
