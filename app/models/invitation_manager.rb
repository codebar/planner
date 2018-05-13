class InvitationManager
  def send_workshop_emails(workshop, audience)
    return 'The workshop is not invitable' unless workshop.invitable?
    invite_students_to_workshop(workshop) unless audience.eql?('coaches')
    invite_coaches_to_workshop(workshop) unless audience.eql?('students')
  end
  handle_asynchronously :send_workshop_emails

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

  def send_course_emails(course)
    students = Member.not_banned.joins(:groups).merge(course.chapter.groups.students)
    students.each do |student|
      invitation = CourseInvitation.new(course: course, member: student)
      invitation.send(:email) if invitation.save
    end
  end
  handle_asynchronously :send_course_emails

  def send_workshop_attendance_reminders(workshop)
    workshop.attendances.where(reminded_at: nil).each do |invitation|
      WorkshopInvitationMailer.attending_reminder(workshop, invitation.member, invitation).deliver_now
      invitation.update_attribute(:reminded_at, Time.zone.now)
    end
  end
  handle_asynchronously :send_workshop_attendance_reminders

  def send_workshop_waiting_list_reminders(workshop)
    workshop.invitations.where(reminded_at: nil).joins(:waiting_list).each do |invitation|
      WorkshopInvitationMailer.waiting_list_reminder(workshop, invitation.member, invitation).deliver_now
      invitation.update_attribute(:reminded_at, Time.zone.now)
    end
  end
  handle_asynchronously :send_workshop_waiting_list_reminders

  def send_change_of_details(workshop, title = 'Change of details', sponsor)
    workshop.invitations.accepted.map do |invitation|
      WorkshopInvitationMailer.change_of_details(workshop, sponsor, invitation.member, invitation, title).deliver_now
    end
  end
  handle_asynchronously :send_change_of_details

  def send_waiting_list_emails(workshop)
    if workshop.host.coach_spots > workshop.attending_coaches.length
      WaitingList.by_workshop(workshop).where_role('Coach').each do |waiting_list|
        WorkshopInvitationMailer.notify_waiting_list(waiting_list.invitation).deliver_now
        waiting_list.destroy
      end

      if workshop.host.seats > workshop.attending_students.length
        WaitingList.by_workshop(workshop).where_role('Student').each do |waiting_list|
          WorkshopInvitationMailer.notify_waiting_list(waiting_list.invitation).deliver_now
          waiting_list.destroy
        end
      end
    end
  end
  handle_asynchronously :send_waiting_list_emails

  private

  def invite_students_to_workshop(workshop)
    chapter_students(workshop.chapter).shuffle.each do |student|
      invitation = WorkshopInvitation.create(workshop: workshop, member: student, role: 'Student')
      invitation.email if invitation.persisted?
    end
  end

  def invite_coaches_to_workshop(workshop)
    chapter_coaches(workshop.chapter).shuffle.each do |coach|
      invitation = WorkshopInvitation.create(workshop: workshop, member: coach, role: 'Coach')
      WorkshopInvitationMailer.invite_coach(workshop, coach, invitation).deliver_now if invitation.persisted?
    end
  end

  def invite_students_to_event(event, chapter)
    chapter_students(chapter).each do |student|
      invitation = Invitation.new(event: event, member: student, role: 'Student')
      EventInvitationMailer.invite_student(event, student, invitation).deliver_now if invitation.save
    end
  end

  def invite_coaches_to_event(event, chapter)
    chapter_coaches(chapter).each do |coach|
      invitation = Invitation.new(event: event, member: coach, role: 'Coach')
      EventInvitationMailer.invite_coach(event, coach, invitation).deliver_now if invitation.save
    end
  end

  def chapter_students(chapter)
    Member.not_banned.joins(:groups).merge(chapter.groups.students)
  end

  def chapter_coaches(chapter)
    Member.not_banned.joins(:groups).merge(chapter.groups.coaches)
  end
end
