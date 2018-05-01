class ChapterPresenter < SimpleDelegator
  def twitter_id
    model.twitter_id || Planner::Application.config.twitter_id
  end

  def twitter_handle
    model.twitter || Planner::Application.config.twitter
  end

  def upcoming_workshops
    model.workshops_upcoming
  end

  def organisers
    @organisers ||= model.permissions.find_by(name: 'organiser').members
  end

  private

  def model
    __getobj__
  end
end
