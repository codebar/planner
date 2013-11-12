require 'spec_helper'

feature 'a member can' do

  context "#session" do
    let(:invitation) { Fabricate(:session_invitation) }
    let(:accepting_invitation_path) { accept_invitation_path(invitation) }
    let(:rejecting_invitation_path) { reject_invitation_path(invitation) }

    let(:set_no_available_slots) { invitation.sessions.host.update_attribute(:seats, 0) }

    it_behaves_like "invitation route"

  end

  context "#course" do
    let(:invitation) { Fabricate(:course_invitation) }
    let(:accepting_invitation_path) { accept_course_invitation_path(invitation) }
    let(:rejecting_invitation_path) { reject_course_invitation_path(invitation) }

    let(:set_no_available_slots) { invitation.course.update_attribute(:seats, 0) }

    it_behaves_like "invitation route"
  end
end

