class ChapterController < ApplicationController
  def show
    chapter = Chapter.find_by!(slug: slug)
    @chapter = ChapterPresenter.new(chapter)

    events = @chapter.upcoming_workshops.includes(:sponsors).sort_by(&:date_and_time).group_by(&:date)
    @upcoming_workshops = events.map.inject({}) { |hash, (key, value)| hash[key] = EventPresenter.decorate_collection(value); hash }
    past_event = @chapter.workshops.most_recent
    past_events = past_event.present? ? [past_event].group_by(&:date) : []
    @latest_workshops = past_events.map.inject({}) { |hash, (key, value)| hash[key] = EventPresenter.decorate_collection(value); hash }
  end

  private

  def slug
    params.permit(:id)[:id]
  end
end
