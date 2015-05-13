require 'spec_helper'

feature 'chapters' do
  let(:member) { Fabricate(:member) }

  context "#creating a new chapter" do
    before do
      login_as_admin(member)
    end

    scenario "an admin can create a new chapter" do
      visit new_admin_chapter_path

      fill_in "Name", with: "codebar Brighton"
      fill_in "Email", with: "brighton@codebar.io"
      fill_in "City", with: "Brighton"

      click_on "Create chapter"

      expect(page).to have_content("Chapter codebar Brighton has been succesfuly created")
    end
  end
end
