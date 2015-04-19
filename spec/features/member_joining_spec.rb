require 'spec_helper'

feature 'a member sign up', pending: "Need to test with github redirect" do
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
      provider: "github",
      uid: '42',
      credentials: {token: "Fake token"},
      info: {
        email: Faker::Internet.email,
        name: Faker::Name.name
      }
    })
  end

  scenario "A new student lands on step 1 after signing up via the front page" do
    visit root_path
    click_on "Learn to code!"
    click_on "Sign in with Github"
    expect(current_path).to eq(step1_member_path)
  end

  scenario "Filling in all the details on step 1 brings the user to step 2" do
    visit root_path
    click_on "Learn to code!"
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

  scenario "Missing any detail on step 1 returns the user to step 1" do
    member = Fabricate(:member, name: nil, surname: nil, email: nil, about_you: nil)
    login member
    member.update(can_log_in: true)
    visit step1_member_path

    # Check for missing first name
    fill_in "member_name", with: ""
    fill_in "member_surname", with: "Smith"
    fill_in "member_email", with: "someone@example.com"
    fill_in "member_about_you", with: "Something"
    click_on "Next"
    expect(current_path).to eq(step1_member_path)
    expect(page).to have_selector('.error')

    # Check for missing last name
    fill_in "member_name", with: "Bob"
    fill_in "member_surname", with: ""
    fill_in "member_email", with: "someone@example.com"
    fill_in "member_about_you", with: "Something"
    click_on "Next"
    expect(current_path).to eq(step1_member_path)
    expect(page).to have_selector('.error')

    # Check for missing email
    fill_in "member_name", with: "Bob"
    fill_in "member_surname", with: "Smith"
    fill_in "member_email", with: ""
    fill_in "member_about_you", with: "Something"
    click_on "Next"
    expect(current_path).to eq(step1_member_path)
    expect(page).to have_selector('.error')

    # Check for missing about you
    fill_in "member_name", with: "Bob"
    fill_in "member_surname", with: "Smith"
    fill_in "member_email", with: "someone@example.com"
    fill_in "member_about_you", with: ""
    click_on "Next"
    expect(current_path).to eq(step1_member_path)
    expect(page).to have_selector('.error')
  end

  scenario "Picking a mailing list on step 2 subscribes you to that list" do
    member = Fabricate(:member)
    group = Fabricate(:group)
    coach_group = Fabricate(:coaches)
    expect(group.members.include? member).to be false
    expect(coach_group.members.include? member).to be false

    login member
    member.update(can_log_in: true)
    visit step2_member_path
    expect(current_path).to eq(step2_member_path) # Make sure we didn't get redirected to step1 for missing details

    expect(page).to have_selector('form')
    click_button "Subscribe to #{group.chapter.name} student invites"
    expect(group.members.include? member).to be true
    expect(coach_group.members.include? member).to be false
  end
end
