require 'spec_helper'

feature "Managing users" do
  let(:member) { Fabricate(:member) }
  let(:admin) { Fabricate(:chapter_organiser) }

  before do
    login admin
  end

  scenario "View a user" do
    visit admin_member_path member

    expect(page).to have_content member.name
    expect(page).to have_content member.email
    expect(page).to have_content member.about_you
  end

  scenario "Add a note to a user" do
    visit admin_member_path member
    expect(page).not_to have_content "Bananas and custard"

    expect {
      fill_in "member_note_note", with: "Bananas and custard"
      click_on "Add note"
    }.to change { MemberNote.all.count}.by 1

    expect(page).to have_content "Member notes (1)"
    expect(page).to have_content "Bananas and custard"
  end
end
