require 'spec_helper'

feature "an admin can" do
  feature 'verify workshop attendees' do

    let(:admin) { Fabricate(:admin) }

    before do
      login(admin)
    end

    scenario 'can verify that a member has attended the meeting' do
      coding_session = Fabricate(:sessions)
      invitation = Fabricate(:session_invitation, sessions: coding_session, attending: true)

      visit admin_root_path
      click_on "Manage attendances"

      click_on "Attended"
      page.should have_content "You have verified #{invitation.member.full_name}'s attendance"
    end
  end
end
