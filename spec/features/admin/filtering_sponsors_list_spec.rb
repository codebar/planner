require 'spec_helper'

RSpec.feature 'Admin filtering sponsors list', type: :feature do
  let(:manager) { Fabricate(:member) }

  before do
    login_as_admin(manager)
  end

  describe 'when visiting the sponsors page' do
    let!(:sponsors) { Fabricate.times(4, :sponsor_with_contacts) }

    before(:each) do
      visit admin_sponsors_path
    end

    scenario 'all the sponsors are displayed' do
      expect(page).to have_css('.sponsor', count: 4)
    end

    describe 'when filtering by name' do
      scenario 'only the sponsor with that name is displayed' do
        fill_in 'sponsors_search[name]', with: sponsors.first.name
        click_on 'Filter'

        expect(page).to have_css('.sponsor', count: 1)
        expect(page).to have_content(sponsors.first.name)
      end
    end
  end
end
