require 'spec_helper'

feature 'member portal' do
  subject { page }
  let(:member) { Fabricate(:member) }

  context "signed in" do
    it "should be able to access the portal menu" do
      login(member)
      visit root_path

      expect(page).to have_selector("#profile")
    end

    it "should not send a welcome email when signing in" do
      expect_any_instance_of(MemberMailer).not_to receive(:welcome)
      expect_any_instance_of(MemberMailer).not_to receive(:welcome_student)
      expect_any_instance_of(MemberMailer).not_to receive(:welcome_coach)

      login(member)
      visit root_path
    end

    it "should allow a user to edit their profile" do
      login member
      visit edit_member_path
      expect(member.name).not_to eq "Bob"
      fill_in "member_name", with: "Bob"
      click_button "Save"
      expect(member.name).to eq "Bob"
    end

    it "should allow a user to join new mailing lists" do
      group = Fabricate(:group)
      expect(group.members.include? member).to be false

      login member
      visit edit_member_path
      click_button "Subscribe"
      expect(group.members.include? member).to be true

    end

    it "should allow a user to leave a mailing list" do
      group = Fabricate(:group)
      group.members << member
      expect(group.members.include? member).to be true

      login member
      visit edit_member_path
      click_button "Subscribed"
      expect(group.members.include? member).to be false
    end
  end

  context "not signed in" do
    it "not should be able to access the portal menu" do
      visit root_path

      expect(page).to_not have_selector("#profile")
    end
  end
end
