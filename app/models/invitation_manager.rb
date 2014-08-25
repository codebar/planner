class InvitationManager

  def self.send_session_emails session
    return "Workshop is not invitable" unless session.invitable?

    session.chapter.groups.students.map(&:members).flatten.uniq.each do |student|
      SessionInvitation.create sessions: session, member: student, role: "Student"
    end

    session.chapter.groups.coaches.map(&:members).flatten.uniq.each do |coach|
      invitation = SessionInvitation.new sessions: session, member: coach, role: "Coach"

      if invitation.save
        SessionInvitationMailer.invite_coach(session, coach, invitation).deliver
      end
    end
  end

  def self.send_course_emails course
    course.chapter.groups.students.map(&:members).flatten.uniq.each do |student|
      CourseInvitation.create course: course, member: student
    end
  end

  def self.send_workshop_attendance_reminders session
    session.attendances.where(reminded_at: nil).each do |invitation|
      SessionInvitationMailer.reminder(session, invitation.member, invitation).deliver
      invitation.update_attribute(:reminded_at, DateTime.now)
    end
  end

  def self.send_spots_available session
    session.invitations.map do |invitation|
      invitation.send_spots_available
    end
  end

  def self.send_change_of_details session, title="Change of details", sponsor
    session.invitations.accepted.map do |invitation|
      SessionInvitationMailer.change_of_details(session, sponsor, invitation.member, invitation, title).deliver
    end
  end
end
