class DashboardController < ApplicationController
  before_action :is_logged_in?, only: %i[dashboard]
  skip_before_action :accept_terms, except: %i[dashboard show]

  DEFAULT_UPCOMING_EVENTS = 5

  helper_method :year_param, :attending_workshops

  def show
    @chapters = Chapter.active.all.order(:created_at)
    @user = current_user ? MemberPresenter.new(current_user) : nil
    @upcoming_workshops = upcoming_events.map.inject({}) do |hash, (key, value)|
      hash[key] = EventPresenter.decorate_collection(value)
      hash
    end
    @attending_ids = attending_workshops
    @testimonials = Testimonial.order(Arel.sql('RANDOM()')).limit(5).includes(:member)
  end

  def dashboard
    @user = MemberPresenter.new(current_user)
    @ordered_events = upcoming_events_for_user.map.inject({}) do |hash, (key, value)|
      hash[key] = EventPresenter.decorate_collection(value)
      hash
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
    workshops = Workshop.upcoming.includes(:chapter, :sponsors)
    all_events(workshops).sort_by(&:date_and_time).group_by(&:date)
  end

  def upcoming_events_for_user
    chapter_workshops = Workshop.upcoming
                                .where(chapter: current_user.chapters)
                                .includes(:chapter, :sponsors)
                                .to_a

    accepted_workshops = current_user.workshop_invitations.accepted
                                     .joins(:workshop)
                                     .merge(Workshop.upcoming)
                                     .includes(workshop: %i[chapter sponsors])
                                     .map(&:workshop)

    all_events(chapter_workshops + accepted_workshops)
      .sort_by(&:date_and_time)
      .group_by(&:date)
  end

  def all_events(workshops)
    meeting = Meeting.includes(:venue).next
    events = Event.includes(:venue, :sponsors).upcoming.take(DEFAULT_UPCOMING_EVENTS)

    [*workshops, *events, meeting].uniq.compact
  end

  def attending_workshops
    current_user.nil? ? Set.new : current_user.workshop_invitations.accepted.pluck(:id).to_set
  end
end
