require 'spec_helper'

feature 'a member sign up', pending: "Need to test with github redirect" do
  before do
    [ "Student", "Coach", "Mentor", "Admin" ].each { |role| Role.create name: role }
  end

  let(:member) { Fabricate(:member) }
  let(:name) { Faker::Name.first_name }

  scenario 'when they fill in all the required details' do
    fill_in_member_details name
    click_on "Join Codebar.io"

    page.should have_content "Thanks for signing up #{name}! #{I18n.t("messages.no_roles")}"
  end

  context "a member can sign up" do
    scenario 'as a Student' do
      log_in_member member

      visit "/member/edit"
      fill_in_member_details name

      check "Student"

      click_on "Join Codebar.io"

      page.should have_content "Thanks for signing up #{name}! You will be receiving notifications for: Students"
    end

    scenario 'as a Coach' do
      fill_in_member_details "Maria"
      check "Coach"

      click_on "Join Codebar.io"

      page.should have_content "Thanks for signing up Maria! You will be receiving notifications for: Coaches"
    end
  end
end

# These tests don't test the oAuth path - they presume success. See
# https://github.com/intridea/omniauth/wiki/Integration-Testing
feature "A new student signs up", js: false do
  before do
    OmniAuth.config.mock_auth[:github] = {
      provider: "Github",
      uid: 42,
      credentials: {token: "Fake token"},
      info: {
        email: Faker::Internet.email,
        name: Faker::Name.name
      }
    }

    [ "Student", "Coach", "Mentor", "Admin" ].each { |role| Role.create name: role }
  end

  scenario "A student can sign up via the front page" do
    visit root_path
    click_on "Students"
    expect(current_path).to eq(new_member_path)

    click_on "Sign in with Github"
    expect(current_path).to eq(edit_member_path)
    expect(page).to have_selector("form")
    fill_in 'member_about_you', with: "I'm a test user and am not actually real"
    click_on "Save"

    expect(page).to have_text "Your details have been updated"
  end
end
