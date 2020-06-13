class VirtualWorkshopInvitationMailerPreview < ActionMailer::Preview
  def attending
    VirtualWorkshopInvitationMailer.attending(Workshop.last, Member.last, WorkshopInvitation.first)
  end

  def attending_reminder
    VirtualWorkshopInvitationMailer.attending_reminder(Workshop.last, Member.last, WorkshopInvitation.first)
  end

  def invite_coach
    VirtualWorkshopInvitationMailer.invite_coach(Workshop.last, Member.last, WorkshopInvitation.first)
  end

  def invite_student
    VirtualWorkshopInvitationMailer.invite_student(Workshop.last, Member.last, WorkshopInvitation.first)
  end

  def waiting_list_reminder
    VirtualWorkshopInvitationMailer.waiting_list_reminder(Workshop.last, Member.last, WorkshopInvitation.first)
  end
end
