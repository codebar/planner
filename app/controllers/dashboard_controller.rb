class DashboardController < ApplicationController
  before_action :is_logged_in?, only: %i[dashboard]
  skip_before_action :accept_terms, except: %i[dashboard show]

  DEFAULT_UPCOMING_EVENTS = 5
  MAX_WORKSHOP_QUERY = 10

  helper_method :year_param

  def show
    @chapters = Chapter.active.all.order(:created_at)
    @user = current_user ? MemberPresenter.new(current_user) : nil
    @upcoming_workshops = upcoming_events.map.each_with_object({}) do |(key, value), hash|
      hash[key] = EventPresenter.decorate_collection(value)
    end
    @has_more_events = total_upcoming_events_count > DEFAULT_UPCOMING_EVENTS

    @testimonials = Testimonial.order(Arel.sql('RANDOM()')).limit(5).includes(:member)
  end

  def dashboard
    @user = MemberPresenter.new(current_user)
    @ordered_events = upcoming_events_for_user.map.each_with_object({}) do |(key, value), hash|
      hash[key] = EventPresenter.decorate_collection(value)
    end
    @announcements = current_user.announcements.active
  end

  def code; end

  def faq; end

  def about; end

  def wall_of_fame
    @coaches_count = top_coach_query.length
    coaches = Member.where(id: top_coach_query
                               .year(year_param))
                    .includes(:skills)
    @pagy, @coaches = pagy(coaches, items: 80)
  end

  def participant_guide; end

  private

  def year_param
    params.permit(:year)[:year]&.to_i || Time.zone.today.year
  end

  def top_coach_query
    WorkshopInvitation.to_coaches
                      .attended
                      .group(:member_id)
                      .order(Arel.sql('COUNT(member_id) DESC'))
                      .select(:member_id)
  end

  def upcoming_events
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

  def total_upcoming_events_count
    workshop_count = Workshop.upcoming.count
    event_count = Event.upcoming.count
    meeting_exists = Meeting.next.present? ? 1 : 0

    workshop_count + event_count + meeting_exists
  end

  def upcoming_events_for_user
    chapter_workshops = Workshop.eager_load(:chapter, :sponsors, :organisers, :permissions)
                                .where(chapter: current_user.chapters)
                                .to_a

    accepted_workshops = current_user.workshop_invitations.accepted
                                     .joins(:workshop)
                                     .merge(Workshop.upcoming)
                                     .eager_load(workshop: %i[chapter sponsors organisers permissions])
                                     .map(&:workshop)

    all_events(chapter_workshops + accepted_workshops)
      .sort_by(&:date_and_time)
      .group_by(&:date)
  end

  def all_events(workshops)
    meeting = Meeting.eager_load(:venue, :organisers, :permissions).next
    events = Event.eager_load(:venue, :sponsors, :sponsorships, :permissions,
                              :organisers).upcoming.take(DEFAULT_UPCOMING_EVENTS)

    [*workshops, *events, meeting].uniq.compact
  end
end
