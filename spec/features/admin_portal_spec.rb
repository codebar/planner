require 'spec_helper'

feature 'admin portal' do

  scenario 'non admin cannot access the admin portal' do
    member = Fabricate(:member)

    login(member)
    visit admin_root_path

    current_url.should eq root_url
  end

  context "an admin user" do
    let(:member) { Fabricate(:admin) }

    before do
      login(member)
    end

    scenario 'can access the admin portal' do
      visit admin_root_path

      current_url.should eq admin_root_url
    end

    scenario 'can verify that a member has attended the meeting' do
      coding_session = Fabricate(:sessions)
      invitation = Fabricate(:session_invitation, sessions: coding_session, attending: true)

      visit admin_root_path

      click_on "Attended"
      page.should have_content "You have verified #{invitation.member.full_name}'s attendance"
    end
  end
end
