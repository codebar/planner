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
      next unless invitation.save

      MeetingInvitationMailer.invite(meeting, invitee, invitation).deliver_now
    rescue StandardError => e
      log_event_meeting_invitation_failure("meeting_id=#{meeting.id}", invitee, e)
    end
  end
  handle_asynchronously :send_meeting_emails

  private

  def invite_students_to_event(event, chapter)
    chapter_students(chapter).each do |student|
      invitation = Invitation.new(event: event, member: student, role: 'Student')
      next unless invitation.save

      EventInvitationMailer.invite_student(event, student, invitation).deliver_now
    rescue StandardError => e
      log_event_meeting_invitation_failure("event_id=#{event.id}", student, e)
    end
  end

  def invite_coaches_to_event(event, chapter)
    chapter_coaches(chapter).each do |coach|
      invitation = Invitation.new(event: event, member: coach, role: 'Coach')
      next unless invitation.save

      EventInvitationMailer.invite_coach(event, coach, invitation).deliver_now
    rescue StandardError => e
      log_event_meeting_invitation_failure("event_id=#{event.id}", coach, e)
    end
  end

  def log_event_meeting_invitation_failure(context, member, error)
    Rails.logger.error(
      '[InvitationManager] Failed to create invitation: ' \
      "#{context}, member_id=#{member.id}, " \
      "error=#{error.class.name}: #{error.message}"
    )
  end

  def chapter_students(chapter)
    Member.in_group(chapter.groups.students)
  end

  def chapter_coaches(chapter)
    Member.in_group(chapter.groups.coaches)
  end
end
