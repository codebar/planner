class MeetingPresenter < EventPresenter

  def sponsors
    model.sponsors
  end

  def description
    model.description
  end

  def organisers
    @organisers ||= model.permissions.find_by_name("organiser").members rescue []
  end

  def attendees_emails
    model.meeting_invitations.accepted.map {|m| m.member.email if m.member }.compact.join(', ')
  end
  
  private

  def model
    __getobj__
  end
end
