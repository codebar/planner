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
  end

  context "not signed in" do
    it "not should be able to access the portal menu" do
      visit root_path

      expect(page).to_not have_selector("#profile")
    end
  end
end
