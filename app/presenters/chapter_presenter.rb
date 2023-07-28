class ChapterPresenter < BasePresenter
  def twitter_id
    model.twitter_id || Rails.application.config.twitter_id
  end

  def twitter_handle
    model.twitter || Rails.application.config.twitter
  end

  def upcoming_workshops
    model.workshops_upcoming
  end

  def organisers
    @organisers ||= model.permissions.find_by(name: 'organiser').members
  end
end
