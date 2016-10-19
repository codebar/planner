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

      expect(page).to have_content("Chapter codebar Brighton has been successfully created")
    end
  end

  context "#editing a chapter" do
    let(:chapter) { Fabricate(:chapter) }


    context "organiser editing their chapter" do
      before do
        login(chapter.organisers.first)
      end

      scenario "an organiser can update a chapter they organise" do
        visit edit_admin_chapter_path(chapter)

        fill_in "Name", with: "codebar Brighton"
        fill_in "Email", with: "brighton@codebar.io"
        fill_in "City", with: "Brighton"

        click_on "Update chapter"

        expect(page).to have_content("Chapter codebar Brighton has been successfully updated")
      end
    end

    context "organiser editing a chapter they do not organise" do
  
      let(:chapter_organiser) { Fabricate(:chapter_organiser)}
      before do
        login(chapter_organiser)
      end

      scenario "an organiser cannot update a chapter they do not organise" do
        visit edit_admin_chapter_path(chapter)

        expect(page).to have_current_path('/')
      end
    end

    context "admin editing a chapter they do not organise" do
  
      # let(:chapter_organiser) { Fabricate(:chapter_organiser)}
      let(:member) { Fabricate(:member)}
      before do
        login_as_admin(member)
      end

      scenario "an organiser cannot update a chapter they do not organise" do
        visit edit_admin_chapter_path(chapter)

        fill_in "Name", with: "codebar Brighton"
        fill_in "Email", with: "brighton@codebar.io"
        fill_in "City", with: "Brighton"

        click_on "Update chapter"


        expect(page).to have_content("Chapter codebar Brighton has been successfully updated")
      end
    end
  end
end
