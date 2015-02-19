class ChapterController < ApplicationController

  def show
    chapter = Chapter.find_by_slug!(slug)
    @chapter = ChapterPresenter.new(chapter)
    @upcoming_workshops = EventPresenter.decorate_collection(@chapter.upcoming_workshops)
  end

  private

  def slug
    params.permit(:id)[:id]
  end
end
