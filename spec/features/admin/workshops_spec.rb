require 'spec_helper'

feature 'Managing workshops' do
  let(:member) { Fabricate(:member) }
  let!(:chapter) { Fabricate(:chapter) }
  let!(:sponsor) { Fabricate(:sponsor) }

  before do
    login_as_admin(member)
    member.add_role(:organiser, Chapter)
  end

  context "creating a new workshop" do
    scenario "Creating a workshop without a note" do
      visit new_admin_workshop_path

      choose chapter.name
      fill_in "Date and time", with: Date.today
      fill_in "Time", with: "11:30"

      click_on "Save"

      expect(page).to have_content "Send Invitations"
    end

    scenario "Creating a workshop with a note" do
      note = Faker::Lorem.paragraph
      visit new_admin_workshop_path
      choose chapter.name
      fill_in "Date and time", with: Date.today
      fill_in "Time", with: "11:30"
      fill_in "Invite note", with: note

      click_on "Save"
      expect(page).to have_content note
    end
  end

  scenario "assigning a host to a workshop" do
    workshop = Fabricate(:sessions_no_sponsor)
    visit admin_workshop_path(workshop)

    within '#host' do
      select sponsor.name, from: "sessions[sponsor_ids]"
    end
    click_on "Set host"

    expect(page).to have_content sponsor.name
  end

  scenario "assigning a host to a workshop" do
    workshop = Fabricate(:sessions_no_sponsor)
    visit admin_workshop_path(workshop)

    within '#sponsors' do
      select sponsor.name, from: "sessions[sponsor_ids]"
    end

    click_on "Add sponsor"
    expect(page).to have_content sponsor.name
  end
end
