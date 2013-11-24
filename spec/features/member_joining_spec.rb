require 'spec_helper'

feature 'a member sign up' do

  before do
    [ "Student", "Coach", "Mentor", "Admin" ].each { |role| Role.create name: role }
  end

  let (:name) { Faker::Name.first_name }

  scenario 'when they fill in all the required details' do
    fill_in_member_details name
    click_on "Join Codebar.io"

    page.should have_content "Thanks for signing up #{name}! #{I18n.t("messages.no_roles")}"
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

  context "a member can not sign up" do
    scenario 'as an Admin' do
      visit new_members_path

      page.should_not have_selector('.collection_check_boxes', text: 'Admin')
    end
  end
end
