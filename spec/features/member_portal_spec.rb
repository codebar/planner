require 'spec_helper'

feature 'Member portal' do
  subject { page }
  let(:member) { Fabricate(:member) }

  context "signed in" do
    it "should be able to access the dashboard" do
      login(member)
      visit dashboard_path

      expect(page).to have_content("Dashboard")
      expect(page).to have_content(member.full_name)
    end

    it "should not send a welcome email when signing in" do
      expect_any_instance_of(MemberMailer).not_to receive(:welcome)
      expect_any_instance_of(MemberMailer).not_to receive(:welcome_student)
      expect_any_instance_of(MemberMailer).not_to receive(:welcome_coach)

      login(member)
      visit root_path
    end

    it "a member can update their details" do
      login member
      visit profile_path

      within "#member_profile" do
        click_on "Update details"
      end

      fill_in "member_name", with: "Jane"
      fill_in "member_surname", with: "Doe"
      click_button "Save"

      expect(page).to have_content("Jane Doe")
    end

    it "a member can subscribe to mailing lists" do
      group = Fabricate(:group)
      login member

      visit profile_path
      within "#member_profile" do
        click_on "Manage subscriptions"
      end
      click_on "Subscribe"

      expect(group.members.include? member).to be true

    end
  end

  context "not signed in" do
    it "not should be able to access the portal menu" do
      visit root_path

      expect(page).to_not have_selector("#profile")
    end
  end
end
