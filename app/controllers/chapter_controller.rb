class ChapterController < ApplicationController
  def show
    @chapter = ChapterPresenter.new(Chapter.active.find_by!(slug: slug))

    upcoming_workshops = upcoming_events_by_chapter(@chapter)
    @upcoming_workshops = event_presenters_by_date(upcoming_workshops)

    past_event = @chapter.workshops.most_recent
    past_events = past_event.present? ? [past_event].group_by(&:date) : []
    @latest_workshops = event_presenters_by_date(past_events)

    @recent_sponsors = Sponsor.recent_for_chapter(@chapter)
  end

  private

  def slug
    params.permit(:id)[:id]
  end

  def upcoming_events_by_chapter(chapter)
    workshops = chapter.upcoming_workshops.includes(:sponsors)
    events = chapter.events.upcoming

    [*workshops, *events].uniq.compact.sort_by(&:date_and_time).group_by(&:date)
  end

  def event_presenters_by_date(events)
    events.map.inject({}) do |hash, (date, value)|
      hash[date] = EventPresenter.decorate_collection(value)
      hash
    end
  end
end
