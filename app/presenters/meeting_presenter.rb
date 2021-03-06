class MeetingPresenter < EventPresenter
  delegate :venue, :description, to: :model

  def attendees_emails
    Member.joins(:meeting_invitations)
          .where('meeting_invitations.meeting_id = ? and meeting_invitations.attending = ?', model.id, true)
          .order_by_email
          .pluck(:email).join(', ')
  end

  def to_s
    model.name
  end

  def admin_path
    Rails.application.routes.url_helpers.admin_meeting_path(model)
  end

  def sponsors
    []
  end

  def time
    I18n.l(model.date_and_time, format: :time_with_zone)
  end
end
