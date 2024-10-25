class InvitationManager
  include WorkshopInvitationManagerConcerns

  def send_event_emails(event, chapter)
    return 'The event is not invitable' unless event.invitable?

    invite_coaches_to_event(event, chapter) unless event.audience.eql?('Students')
    invite_students_to_event(event, chapter) unless event.audience.eql?('Coaches')
  end
  handle_asynchronously :send_event_emails

  def send_monthly_attendance_reminder_emails(monthly)
    invitees = Member.attending_meeting(monthly)
    invitees.each do |member|
      MeetingInvitationMailer.attendance_reminder(monthly, member)
    end
  end
  handle_asynchronously :send_monthly_attendance_reminder_emails

  def send_meeting_emails(meeting)
    meeting.invitees.not_banned.each do |invitee|
      invitation = MeetingInvitation.new(meeting: meeting, member: invitee, role: 'Participant')
      MeetingInvitationMailer.invite(meeting, invitee, invitation).deliver_now if invitation.save
    end
  end
  handle_asynchronously :send_meeting_emails

  private

  def invite_students_to_event(event, chapter)
    chapter_students(chapter).each do |student|
      invitation = Invitation.new(event: event, member: student, role: 'Student')
      EventInvitationMailer.invite_student(event, student, invitation).deliver_now if invitation.save
    end
  end
  handle_asynchronously :invite_students_to_event

  def invite_coaches_to_event(event, chapter)
    chapter_coaches(chapter).each do |coach|
      invitation = Invitation.new(event: event, member: coach, role: 'Coach')
      EventInvitationMailer.invite_coach(event, coach, invitation).deliver_now if invitation.save
    end
  end
  handle_asynchronously :invite_coaches_to_event

  def chapter_students(chapter)
    Member.in_group(chapter.groups.students)
  end

  def chapter_coaches(chapter)
    Member.in_group(chapter.groups.coaches)
  end
end
