class InvitationManager

  def self.send_session_emails session
    Member.students.each do |student|
      SessionInvitation.create sessions: session, member: student, role: "Student"
    end
  end

  def self.send_course_emails course
    Member.students.each do |student|
      CourseInvitation.create course: course, member: student
    end
  end

  def self.send_session_reminders session
    session.attending_invitations.map do |invitation|
      invitation.send_reminder
    end
  end

end
