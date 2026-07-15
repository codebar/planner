class DashboardQuery
  DEFAULT_UPCOMING_EVENTS = 5
  MAX_WORKSHOP_QUERY = 10

  def self.upcoming_events
    workshops = Workshop.eager_load(:chapter, :sponsors, :organisers, :permissions)
                        .today_and_upcoming
                        .limit(MAX_WORKSHOP_QUERY)
                        .to_a
    sorted_events = all_events(workshops).sort_by(&:date_and_time)

    limited_events = []
    dates_shown = 0
    prev_date = nil

    sorted_events.each do |event|
      dates_shown += 1 if event.date != prev_date
      prev_date = event.date
      break if dates_shown > 3 || limited_events.size >= DEFAULT_UPCOMING_EVENTS

      limited_events << event
    end

    limited_events.group_by(&:date)
  end

  def self.upcoming_events_for_user(member)
    chapter_workshops = Workshop.upcoming
                                .eager_load(:chapter, :sponsors, :organisers, :permissions)
                                .where(chapter: member.chapters)
                                .to_a

    accepted_workshops = member.workshop_invitations.accepted
                               .joins(:workshop)
                               .merge(Workshop.upcoming)
                               .eager_load(workshop: %i[chapter sponsors organisers permissions])
                               .map(&:workshop)

    all_events(chapter_workshops + accepted_workshops)
      .sort_by(&:date_and_time)
      .group_by(&:date)
  end

  def self.total_upcoming_events_count
    workshop_count = Workshop.upcoming.count
    event_count = Event.upcoming.count
    meeting_exists = Meeting.next.present? ? 1 : 0

    workshop_count + event_count + meeting_exists
  end

  def self.all_events(workshops)
    meeting = Meeting.eager_load(:venue, :organisers, :permissions).next
    events = Event.eager_load(:venue, :sponsors, :sponsorships, :permissions,
                              :organisers).upcoming.take(DEFAULT_UPCOMING_EVENTS)

    [*workshops, *events, meeting].uniq.compact
  end
  private_class_method :all_events
end
