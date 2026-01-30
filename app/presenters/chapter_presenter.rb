class ChapterPresenter < BasePresenter
  def upcoming_workshops
    model.workshops_upcoming
  end

  def organisers
    chapter = model.permissions.find_by(name: 'organiser')

    @organisers ||= chapter ? chapter.members : []
  end
end
