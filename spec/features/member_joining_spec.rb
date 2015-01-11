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
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
      provider: "Github",
      uid: 42,
      credentials: {token: "Fake token"},
      info: {
        email: Faker::Internet.email,
        name: Faker::Name.name
      }
    })

    [ "Student", "Coach", "Mentor", "Admin" ].each { |role| Role.create name: role }
  end

  scenario "A new student lands on step 1 after signing up via the front page" do
    visit root_path
    click_on "Students"
    click_on "Sign in with Github"
    expect(current_path).to eq(step1_member_path)
  end

  scenario "Filling in all the details on step 1 brings the user to step 2" do
    visit root_path
    click_on "Students"
    click_on "Sign in with Github"
    expect(page).to have_selector("form")
    fill_in "member_name", with: "Bob"
    fill_in "member_surname", with: "Smith"
    fill_in "member_email", with: "someone@example.com"
    fill_in "member_about_you", with: "I'm a test user created via the RSpec feature specs."
    click_on "Next"
    expect(current_path).to eq(step2_member_path)

    member = Member.last
    expect(member.name).to eq("Bob")
    expect(member.surname).to eq("Smith")
    expect(member.email).to eq("someone@example.com")
    expect(member.about_you).to eq("I'm a test user created via the RSpec feature specs.")
  end

  scenario "A student can sign up via the front page", pending: "Transform into test for edit page" do
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
