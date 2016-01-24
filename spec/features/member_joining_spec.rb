require 'spec_helper'

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
    click_button group.chapter.name
    expect(group.members.include? member).to be true
    expect(coach_group.members.include? member).to be false
  end
end
