class WorkshopInvitationMailerPreview < ActionMailer::Preview
  def invite_coach
    WorkshopInvitationMailer.invite_coach(Workshop.last, Member.last, WorkshopInvitation.first)
  end

  def invite_student
    WorkshopInvitationMailer.invite_student(Workshop.last, Member.last, WorkshopInvitation.first)
  end

  def attending
    WorkshopInvitationMailer.attending(Workshop.last, Member.last, WorkshopInvitation.first)
  end

  def attending_reminder
    WorkshopInvitationMailer.attending_reminder(Workshop.last, Member.last, WorkshopInvitation.first)
  end

  def waiting_list_reminder
    WorkshopInvitationMailer.waiting_list_reminder(Workshop.last, Member.last, WorkshopInvitation.first)
  end

  def notify_waiting_list
    WorkshopInvitationMailer.notify_waiting_list(WorkshopInvitation.first)
  end
end
