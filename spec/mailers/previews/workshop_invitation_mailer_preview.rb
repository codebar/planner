class WorkshopInvitationMailerPreview < ActionMailer::Preview
  def invite_coach
    WorkshopInvitationMailer.invite_coach(Workshop.first, Member.last, WorkshopInvitation.first)
  end

  def invite_student
    WorkshopInvitationMailer.invite_coach(Workshop.first, Member.first, SessionInvitation.first)
  end
end
