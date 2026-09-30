class ChapterController < ApplicationController
  def show
    @chapter = ChapterPresenter.new(Chapter.active.find_by!(slug:))

    upcoming_workshops = upcoming_events_by_chapter(@chapter)
    @upcoming_workshops = event_presenters_by_date(upcoming_workshops)
    past_event = @chapter.workshops.most_recent
    @latest_workshops = event_presenters_by_date(past_event ? [past_event] : [])

    @recent_sponsors = Sponsor.recent_for_chapter(@chapter).to_a

    fresh_when(etag: chapter_show_etag(upcoming_workshops, past_event)) unless logged_in?
  end

  private

  # Mirrors the fragment keys in the chapter show view: the anonymous ETag must
  # rotate when any record whose content is rendered changes, even if it does
  # not touch chapters.updated_at. The card records are eager-loaded, so
  # flattening them here issues no extra queries. The full key list is kept
  # (not collapsed to a max) so every record change rotates the ETag.
  def chapter_show_etag(upcoming_records, past_event)
    card_records = rendered_card_records(upcoming_records) + rendered_card_records(past_event ? [past_event] : [])

    [
      @chapter,
      @chapter.organisers,
      @recent_sponsors,
      card_records.map(&:cache_key_with_version),
      I18n.locale,
      :v1
    ]
  end

  # The records whose content the event cards render: the record itself, its
  # venue (events) or host (workshops), sponsors and organisers.
  def rendered_card_records(records)
    records.flat_map do |record|
      [record, record.try(:venue) || record.try(:host)] + record.sponsors.to_a + record.organisers.to_a
    end.compact
  end

  def slug
    params.permit(:id)[:id]
  end

  def upcoming_events_by_chapter(chapter)
    workshops = chapter.upcoming_workshops.eager_load(:sponsors, :organisers).preload(workshop_host: :sponsor)
    # :sponsors already joins through :sponsorships; nothing here reads the
    # sponsorship rows themselves.
    events = chapter.events.upcoming.eager_load(:venue, :sponsors, :organisers)

    [*workshops, *events].uniq.sort_by(&:date_and_time)
  end

  def event_presenters_by_date(records)
    records.group_by(&:date).each_with_object({}) do |(date, value), hash|
      hash[date] = EventPresenter.decorate_collection(value)
    end
  end
end
