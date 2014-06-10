require 'spec_helper'

feature 'chapters' do

  context "#creating a new chapter" do
    let(:admin) { Fabricate(:admin) }

    before do
      login(admin)
    end

    scenario "an admin can create a new chapter" do

      visit new_admin_chapter_path

      fill_in "Name", with: "Codebar Brighton"
      fill_in "City", with: "Brighton"

      click_on "Create chapter"

      expect(page).to have_content("Chapter Codebar Brighton has been succesfuly created")
    end
  end
end
