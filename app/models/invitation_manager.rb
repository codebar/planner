class InvitationManager

  def self.send_session_emails session
    Member.students.each do |student|
      SessionInvitation.create sessions: session, member: student
    end
  end

  def self.send_course_emails course
    Member.students.each do |student|
      CourseInvitation.create course: course, member: student
    end
  end

  def self.send_session_reminders session
    session.invitations.where(attending: true).each do |invitation|
      invitation.send_reminder
    end
  end

end
