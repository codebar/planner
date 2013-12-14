require 'spec_helper'

feature 'a member sign up' do

  before do
    [ "Student", "Coach", "Mentor", "Admin" ].each { |role| Role.create name: role }
  end

  let (:name) { Faker::Name.first_name }
  let (:email) { ActionMailer::Base.deliveries.last }

  scenario 'when they fill in all the required details' do
    fill_in_member_details name
    fill_in "Email", with: 'joe@test.com'
    click_on "Join Codebar.io"

    page.should have_content "Thanks for signing up #{name}! #{I18n.t("messages.no_roles")}"
    email.to.should == ['joe@test.com']
  end

  context "a member can sign up" do
    scenario 'as a Student' do
      fill_in_member_details name
      fill_in "Email", with: 'joe@test.com'
      check "Student"

      click_on "Join Codebar.io"

      page.should have_content "Thanks for signing up #{name}! You will be receiving notifications for: Students"
      email.to.should == ['joe@test.com']
    end

    scenario 'as a Coach' do
      fill_in_member_details "Maria"
      fill_in "Email", with: 'maria@test.com'
      check "Coach"

      click_on "Join Codebar.io"

      page.should have_content "Thanks for signing up Maria! You will be receiving notifications for: Coaches"
      email.to.should == ['maria@test.com']
    end
  end

  context "a member can not sign up" do
    scenario 'as an Admin' do
      visit new_members_path

      page.should_not have_selector('.collection_check_boxes', text: 'Admin')
    end
  end
end
