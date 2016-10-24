class InvitationManager

  def send_session_emails workshop
    return "The workshop is not invitable" unless workshop.invitable?

    workshop.chapter.groups.students.map(&:members).flatten.uniq.shuffle.each do |student|
      next if student.banned?
      so = SessionInvitation.create workshop: workshop, member: student, role: "Student"
      so.email if so.persisted?
    end

    workshop.chapter.groups.coaches.map(&:members).flatten.uniq.shuffle.each do |coach|
      next if coach.banned?
      invitation = SessionInvitation.new workshop: workshop, member: coach, role: "Coach"

      if invitation.save
        SessionInvitationMailer.invite_coach(workshop, coach, invitation).deliver_now
        Rails.logger.debug("Invitation to #{coach.email} sent")
      else
        Rails.logger.debug("Invitation to #{coach.email} not sent as invitation could not be saved")
      end
    end
  end

  handle_asynchronously :send_session_emails

  def send_event_emails event, chapter
    return "The event is not invitable" unless event.invitable?

    students = chapter.groups.students.map(&:members).flatten.uniq
    coaches = chapter.groups.coaches.map(&:members).flatten.uniq

    if event.audience == 'Students'
      students.each do |student|
        next if student.banned?
        invitation = Invitation.new(event: event, member: student, role: "Student")
        EventInvitationMailer.invite_student(event, student, invitation).deliver_now if invitation.save
      end
    elsif event.audience == 'Coaches'
      coaches.each do |coach|
        next if coach.banned?
        invitation = Invitation.new(event: event, member: coach, role: "Coach")
        EventInvitationMailer.invite_coach(event, coach, invitation).deliver_now if invitation.save
      end
    else
      students.each do |student|
        next if student.banned?
        invitation = Invitation.new(event: event, member: student, role: "Student")
        EventInvitationMailer.invite_student(event, student, invitation).deliver_now if invitation.save
      end

      coaches.each do |coach|
        next if coach.banned?
        invitation = Invitation.new(event: event, member: coach, role: "Coach")
        EventInvitationMailer.invite_coach(event, coach, invitation).deliver_now if invitation.save
      end
    end
  end

  # handle_asynchronously :send_event_emails

  def self.send_monthly_attendance_reminder_emails monthly
    monthly.attendances.map(&:member).each do |member|
      MeetingInvitationMailer.attendance_reminder(monthly, member)
    end
  end

  def self.send_monthly_attendance_reminder_emails monthly
    monthly.attendances.map(&:member).each do |member|
      MeetingInvitationMailer.attendance_reminder(monthly, member)
    end
  end

  def self.send_monthly_attendance_reminder_emails monthly
    monthly.attendances.map(&:member).each do |member|
      MeetingInvitationMailer.attendance_reminder(monthly, member)
    end
  end

  def self.send_monthly_attendance_reminder_emails monthly
    monthly.attendances.map(&:member).each do |member|
      MeetingInvitationMailer.attendance_reminder(monthly, member)
    end
  end

  def self.send_course_emails course
    course.chapter.groups.students.map(&:members).flatten.uniq.each do |student|
      invitation  = CourseInvitation.new(course: course, member: student)
      invitation.send(:email) if invitation.save
    end
  end

  def self.send_workshop_attendance_reminders workshop
    workshop.attendances.where(reminded_at: nil).each do |invitation|
      SessionInvitationMailer.attending_reminder(workshop, invitation.member, invitation).deliver_now
      invitation.update_attribute(:reminded_at, Time.zone.now)
    end
  end

  def self.send_workshop_waiting_list_reminders workshop
    # Only send out reminders to people where reminded_at is nil, ie. falsey.
    workshop.waiting_list.reject(&:reminded_at).each do |invitation|
      SessionInvitationMailer.waiting_list_reminder(workshop, invitation.member, invitation).deliver_now
      invitation.update_attribute(:reminded_at, Time.zone.now)
    end
  end

  def self.send_change_of_details workshop, title="Change of details", sponsor
    workshop.invitations.accepted.map do |invitation|
      SessionInvitationMailer.change_of_details(workshop, sponsor, invitation.member, invitation, title).deliver_now
    end
  end

  def self.send_waiting_list_emails(workshop)
    if workshop.host.coach_spots > workshop.attending_coaches.length
      WaitingList.by_workshop(workshop).where_role("Coach").each do |waiting_list|
        SessionInvitationMailer.notify_waiting_list(waiting_list.invitation).deliver_now
        waiting_list.delete
      end

      if workshop.host.seats > workshop.attending_students.length
        WaitingList.by_workshop(workshop).where_role("Student").each do |waiting_list|
          SessionInvitationMailer.notify_waiting_list(waiting_list.invitation).deliver_now
          waiting_list.delete
        end
      end
    end
  end
end
