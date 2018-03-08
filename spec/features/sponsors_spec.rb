require 'spec_helper'

feature 'Sponsors' do
  context 'Listing' do
    scenario 'can see a listing of all non expired job posts' do
      gold_sponsor = Fabricate.create(:sponsor, level: :gold)
      standard_sponsor = Fabricate.create(:sponsor)
      hidden_sponsor = Fabricate.create(:sponsor, level: :hidden)

      visit root_path
      click_link('Sponsors', match: :first)

      expect(page).to have_css("img[src*='#{gold_sponsor.avatar.url}']")
      expect(page).to have_css("img[src*='#{standard_sponsor.avatar.url}']")
      expect(page).to_not have_css("img[src*='#{hidden_sponsor.avatar.url}']")
    end
  end
end
