require 'spec_helper'

describe SessionInvitation do
  let(:invitation) { Fabricate(:session_invitation) }
  let!(:accepted_invitation) { 2.times {  Fabricate(:session_invitation, attending: true) } }

  it_behaves_like InvitationConcerns

  it "#send_reminder" do
    invitation.update_attribute(:attending, true)
    mailer = double(SessionInvitationMailer, deliver: nil)

    SessionInvitationMailer.should_receive(:remind_student).
      with(invitation.sessions, invitation.member, invitation).and_return(mailer)

    invitation.send_reminder
  end
end
