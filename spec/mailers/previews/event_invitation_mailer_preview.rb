class EventInvitationMailerPreview < ActionMailer::Preview
  def invite_student
    EventInvitationMailer.invite_student(Event.last, Member.last, Invitation.last)
  end

  def invite_coach
    EventInvitationMailer.invite_coach(Event.last, Member.last, Invitation.last)
  end

  def attending
    EventInvitationMailer.attending(Event.last, Member.last, Invitation.last)
  end
end
