class ChapterController < ApplicationController
  def show
    chapter = Chapter.find_by_slug(slug)
    redirect_to root_path, notice: "We can't find the chapter you are looking for" and return if chapter.nil?

    @chapter = ChapterPresenter.new(chapter)

    events = @chapter.upcoming_workshops.sort_by(&:date_and_time).group_by(&:date)
    @upcoming_workshops = events.map.inject({}) { |hash, (key, value)| hash[key] = EventPresenter.decorate_collection(value); hash }
    past_events = [@chapter.workshops.most_recent].compact.sort_by(&:date_and_time).group_by(&:date)
    @latest_workshops = past_events.map.inject({}) { |hash, (key, value)| hash[key] = EventPresenter.decorate_collection(value); hash }
  end

  private

  def slug
    params.permit(:id)[:id]
  end
end
