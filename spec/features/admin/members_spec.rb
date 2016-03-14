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
    fill_in "member_note_note", with: "Bananas and custard"
    click_on "Add note"

    expect(page).to have_content "Bananas and custard"
  end

  scenario "Ban a user" do
    visit admin_member_path member
    click_on "Ban"

    select "Violated attendance policy", from: "ban_reason"
    fill_in "ban_note", with: Faker::Lorem.word
    fill_in "ban_expires_at", with: Date.today+1.month
    click_on "Ban user"

    expect(page).to have_content "The user has been banned"
  end

end
