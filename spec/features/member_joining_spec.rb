require 'spec_helper'

feature 'a member can sign up', wip: true do

  before do
    [ "Student", "Coach", "Mentor" ].each { |role| Role.create name: role }
  end

  let (:name) { Faker::Name.first_name }

  scenario 'when they fill in all the required details' do
    fill_in_member_details name
    click_on "Join Codebar.io"

    page.should have_content "Thanks for signing up #{name}! You have not signed up for any notifications. If you change your mind, send us an email at meetins@codebar.io so we can change your settings"
  end

  context "a member can sign up" do
    scenario 'as a Student' do
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
