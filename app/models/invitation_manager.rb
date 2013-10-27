class InvitationManager

  def self.email_students session
    Member.students.each do |student|
      Invitation.create sessions: session, member: student
    end
  end

end
