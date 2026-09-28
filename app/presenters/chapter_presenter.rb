class ChapterPresenter < BasePresenter
  def upcoming_workshops
    model.workshops_upcoming
  end

  def organisers
    @organisers ||= model.permissions.find_by(name: 'organiser')&.members.to_a
  end
end
