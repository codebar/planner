class MeetingInvitationMailerPreview < ActionMailer::Preview
  def invite
    meeting = Meeting.last
    member = Member.last

    # In the real work, MeetingInvitation should have been created already and a
    # token should have been assigned. The next lines are for testing purposes.
    invitation = MeetingInvitation.new(meeting: meeting, member: member)
    invitation.token = "tokenExample28XIcd6IxQ"

    MeetingInvitationMailer.invite(meeting, member, invitation)
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
