class InvitationManager

  def send_session_emails session
    return "The workshop is not invitable" unless session.invitable?

    session.chapter.groups.students.map(&:members).flatten.uniq.shuffle.each do |student|
      next if student.banned?
      so = SessionInvitation.create sessions: session, member: student, role: "Student"
      so.email if so.persisted?
    end

    session.chapter.groups.coaches.map(&:members).flatten.uniq.shuffle.each do |coach|
      next if coach.banned?
      invitation = SessionInvitation.new sessions: session, member: coach, role: "Coach"

      if invitation.save
        SessionInvitationMailer.invite_coach(session, coach, invitation).deliver
        Rails.logger.debug("Invitation to #{coach.email} sent")
      else
        Rails.logger.debug("Invitation to #{coach.email} not sent as invitation could not be saved")
      end
    end
  end

  handle_asynchronously :send_session_emails

  def send_event_emails event, chapter
    return "The event is not invitable" unless event.invitable?

    chapter.groups.students.map(&:members).flatten.uniq.each do |student|
      invitation = Invitation.new(event: event, member: student, role: "Student")
      EventInvitationMailer.invite_student(event, student, invitation).deliver if invitation.save
    end

    chapter.groups.coaches.map(&:members).flatten.uniq.each do |coach|
      invitation = Invitation.new(event: event, member: coach, role: "Coach")
      EventInvitationMailer.invite_coach(event, coach, invitation).deliver if invitation.save
    end
  end

  handle_asynchronously :send_event_emails

  def self.send_course_emails course
    course.chapter.groups.students.map(&:members).flatten.uniq.each do |student|
      invitation  = CourseInvitation.new(course: course, member: student)
      invitation.send(:email) if invitation.save
    end
  end

  def self.send_workshop_attendance_reminders session
    session.attendances.where(reminded_at: nil).each do |invitation|
      SessionInvitationMailer.attending_reminder(session, invitation.member, invitation).deliver
      invitation.update_attribute(:reminded_at, Time.zone.now)
    end
  end

  def self.send_workshop_waiting_list_reminders session
    # Only send out reminders to people where reminded_at is nil, ie. falsey.
    session.waiting_list.reject(&:reminded_at).each do |invitation|
      SessionInvitationMailer.waiting_list_reminder(session, invitation.member, invitation).deliver
      invitation.update_attribute(:reminded_at, Time.zone.now)
    end
  end

  def self.send_change_of_details session, title="Change of details", sponsor
    session.invitations.accepted.map do |invitation|
      SessionInvitationMailer.change_of_details(session, sponsor, invitation.member, invitation, title).deliver
    end
  end

  def self.send_waiting_list_emails(workshop)
    if workshop.host.coach_spots > workshop.attending_coaches.length
      WaitingList.by_workshop(workshop).where_role("Coach").each do |waiting_list|
        SessionInvitationMailer.notify_waiting_list(waiting_list.invitation).deliver
        waiting_list.delete
      end

      if workshop.host.seats > workshop.attending_students.length
        WaitingList.by_workshop(workshop).where_role("Student").each do |waiting_list|
          SessionInvitationMailer.notify_waiting_list(waiting_list.invitation).deliver
          waiting_list.delete
        end
      end
    end
  end
end
