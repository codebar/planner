require 'spec_helper'

feature 'admin groups' do

  context "#creating a new group" do
    let(:admin) { Fabricate(:admin) }
    let!(:chapter) { Fabricate(:chapter, name: "Brighton") }

    before do
      login(admin)
    end

    scenario "an admin can create a new chapter" do

      visit new_admin_group_path
      fill_in "Name", with: "Students"
      select "Brighton", from: "group[chapter_id]"

      click_on "Create group"

      expect(page).to have_content("Group Students for chapter Brighton has been succesfuly created")
    end
  end
end
