require 'spec_helper'

feature 'a member can sign up', wip: true do

  before do
    [ "Student", "Coach", "Mentor" ].each { |role| Role.create name: role }
  end

  let (:name) { Faker::Name.first_name }

  scenario 'when they fill in all the required details' do
    join_as_member
    click_on "Join Codebar.io"

    page.should have_content "Thanks for signing up #{name}! You have not signed up for any notifications. If you change your mind, send us an email at meetins@codebar.io so we can change your settings"
  end

  context "a member can sign up" do
    scenario 'as a Student' do
      join_as_member
      check "Student"

      click_on "Join Codebar.io"

      page.should have_content "Thanks for signing up #{name}! You will be receiving notifications for: Students"
    end
  end

  private

  def join_as_member
    visit root_path
    click_on "Become a member"

    fill_in "Name", with: name
    fill_in "Surname", with: Faker::Name.last_name

    fill_in "Email", with: Faker::Internet.email
    fill_in "Twitter", with: Faker::Name.first_name

    fill_in "Tell us a little bit about yourself", with: Faker::Lorem.paragraph

  end
end
