class SessionInvitationMailerPreview < ActionMailer::Preview
  def invite_coach
    SessionInvitationMailer.invite_coach(Workshop.first, Member.last, SessionInvitation.first)
  end

  def invite_student
    SessionInvitationMailer.invite_coach(Workshop.first, Member.first, SessionInvitation.first)
  end
end
