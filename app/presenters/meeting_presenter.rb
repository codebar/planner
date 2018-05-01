class MeetingPresenter < EventPresenter
  def venue
    model.venue
  end

  def description
    model.description
  end

  def organisers
    @organisers ||= model.permissions.find_by(name: 'organiser').members rescue []
  end

  def attendees_emails
    model.invitations.accepted.map { |m| m.member.email if m.member }.compact.join(', ')
  end

  def to_s
    model.name
  end

  def admin_path
    Rails.application.routes.url_helpers.admin_meeting_path(model)
  end

  private

  def model
    __getobj__
  end
end
