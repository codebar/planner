class MeetingInvitationMailerPreview < ActionMailer::Preview
  def invite
    MeetingInvitationMailer.invite(Meeting.first, Member.last)
  end
end
