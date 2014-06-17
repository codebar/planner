require 'spec_helper'

feature "an admin can" do
  feature 'verify workshop attendees' do

    let(:member) { Fabricate(:member) }
    let(:chapter) { Fabricate(:chapter) }

    before do
      login_as_admin(member)
    end

    scenario 'can verify that a member has attended the meeting' do
      workshop = Fabricate(:sessions, chapter: chapter)
      invitation = Fabricate(:session_invitation, sessions: workshop, attending: true)

      visit admin_workshop_path(workshop)

      click_on "Attended"
      page.should have_content "You have verified #{invitation.member.full_name}'s attendance"
    end
  end
end
