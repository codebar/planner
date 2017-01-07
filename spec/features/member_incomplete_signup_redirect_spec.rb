require 'spec_helper'

feature 'A new member signs up', js: false do
  before do
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
      provider: "github",
      uid: '42',
      credentials: {token: "Fake token"},
      info: {
        email: Faker::Internet.email,
        name: Faker::Name.name
      }
    })
  end

  scenario 'Member visits tutorial page before completing step 1 of registration' do
    member = Fabricate(:member)
    member.update(can_log_in: :true)
    login member
    visit step1_member_path

    within('.top-bar') do
      click_on 'Tutorials'
    end

    expect(current_path).to eq(step1_member_path)
    expect(page).to have_content("We noticed that you did not finish signing up. Please complete your registration.")
  end

  scenario "Member completes step 1 but doesn't subscribe on step 2"  do
    visit new_member_path
    click_on "Sign up as a coach"

    fill_in "member_pronouns", with: "she"
    fill_in "member_name", with: "Jane"
    fill_in "member_surname", with: "Doe"
    fill_in "member_email", with: "jane@codebar.io"
    fill_in "member_about_you", with: Faker::Lorem.paragraph
    click_on "Next"

    expect(current_path).to eq(step2_member_path)

    click_on "Done"

    expect(current_path).to eq(step2_member_path)
    expect(page).to have_content("Please subscribe to at least one group before continuing.")
  end
end
