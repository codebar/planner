class ChapterController < ApplicationController

  def show
    chapter = Chapter.where("lower(name) = ?", name.downcase).first
    @chapter = ChapterPresenter.new(chapter)
    @upcoming_workshops = EventPresenter.decorate_collection(@chapter.upcoming_workshops)
  end

  private

  def name
    params.permit(:id)[:id]
  end
end
