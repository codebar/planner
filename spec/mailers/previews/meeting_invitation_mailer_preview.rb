class MeetingInvitationMailerPreview < ActionMailer::Preview
  def invite
    MeetingInvitationMailer.invite(Meeting.last, Member.last)
  end

  def attending
    MeetingInvitationMailer.attending(Meeting.last, Member.last)
  end

  def approve_from_waitlist
    MeetingInvitationMailer.approve_from_waitlist(Meeting.last, Member.last)
  end

  def attendance_reminder
    MeetingInvitationMailer.attendance_reminder(Meeting.last, Member.last)
  end
end
