class ChapterPresenter < BasePresenter
  def upcoming_workshops
    model.workshops_upcoming
  end

  def organisers
    @organisers ||= model.permissions.to_a.find { |permission| permission.name == 'organiser' }&.members.to_a
  end
end
