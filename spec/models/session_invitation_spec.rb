require 'spec_helper'

describe SessionInvitation do
  let(:invitation) { Fabricate(:student_session_invitation) }
  let!(:accepted_invitation) { 2.times {  Fabricate(:session_invitation, attending: true) } }

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

  context "scopes" do
    let!(:attended) { 3.times.map { Fabricate(:attended_session_invitation) } }
    let!(:to_students) { 6.times.map { Fabricate(:student_session_invitation) } }
    let!(:to_coaches) { 4.times.map { Fabricate(:coach_session_invitation) } }

    it "#attended" do
      SessionInvitation.attended.count.should eq attended.length
    end

    it "#to_coaches" do
      SessionInvitation.to_coaches.count.should eq to_coaches.length
    end

    it "#to_student" do
      SessionInvitation.to_students.count.should eq to_students.length
    end
  end

end
