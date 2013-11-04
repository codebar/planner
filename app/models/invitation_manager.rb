class InvitationManager

  def self.email_students session
    Member.students.each do |student|
      SessionInvitation.create sessions: session, member: student
    end
  end

end
