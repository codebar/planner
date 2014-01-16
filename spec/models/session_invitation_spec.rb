require 'spec_helper'

describe SessionInvitation do

  context "methods" do
    let(:invitation) { Fabricate(:student_session_invitation) }
    let!(:accepted_invitation) { 2.times { Fabricate(:session_invitation, attending: true) } }

    it_behaves_like InvitationConcerns

    it "#send_reminder" do
      invitation.update_attribute(:attending, true)
      mailer = double(SessionInvitationMailer, deliver: nil)

      SessionInvitationMailer.should_receive(:remind_student).
        with(invitation.sessions, invitation.member, invitation).and_return(mailer)

      invitation.send_reminder
    end

    it "#send_spots_available" do
      invitation.update_attribute(:attending, nil)
      mailer = double(SessionInvitationMailer, deliver: nil)

      SessionInvitationMailer.should_receive(:spots_available).
        with(invitation.sessions, invitation.member, invitation).and_return(mailer)

      invitation.send_spots_available
    end
  end

  context "scopes" do

    it "#attended" do
      4.times { Fabricate(:attended_session_invitation) }

      SessionInvitation.attended.count.should eq 4
    end

    it "#to_coaches" do
      6.times { Fabricate(:coach_session_invitation) }

      SessionInvitation.to_coaches.count.should eq 6
    end

    it "#to_student" do
      4.times { Fabricate(:student_session_invitation) }

      SessionInvitation.to_students.count.should eq 4
    end
  end

end
