class DashboardController < ApplicationController
  before_action :require_login, only: %i[dashboard]
  skip_before_action :accept_terms, except: %i[dashboard show]

  helper_method :year_param

  def show
    @chapters = Chapter.active.all.order(:created_at)
    @user = current_user ? MemberPresenter.new(current_user) : nil
    @upcoming_workshops = DashboardQuery.upcoming_events.map.each_with_object({}) do |(key, value), hash|
      hash[key] = EventPresenter.decorate_collection(value)
    end
    @has_more_events = DashboardQuery.total_upcoming_events_count > DashboardQuery::DEFAULT_UPCOMING_EVENTS

    @testimonials = Testimonial.order(Arel.sql('RANDOM()')).limit(5).includes(:member)
  end

  def dashboard
    @user = MemberPresenter.new(current_user)
    @ordered_events = DashboardQuery.upcoming_events_for_user(current_user)
                                    .map.each_with_object({}) do |(key, value), hash|
      hash[key] = EventPresenter.decorate_collection(value)
    end
    @announcements = current_user.announcements.active
  end

  def code; end

  def faq; end

  def about; end

  def wall_of_fame
    key = "coaches/wall_of_fame/v1/#{Time.zone.today}/#{year_param}/#{params[:page] || 1}/#{I18n.locale}"
    body = Rails.cache.fetch(key, expires_in: 24.hours) do
      @coaches_count = WorkshopInvitation.to_coaches.attended.distinct.count(:member_id)
      coaches = Member.where(id: top_coach_query
                                 .year(year_param))
                      .includes(:skills)
      @pagy, @coaches = pagy(coaches)
      render_to_string(layout: false)
    end
    # The layout renders fresh so asset URLs and meta tags are never stale;
    # bump v1 when the wall_of_fame view or its partials change.
    # The cached body is fully rendered template output; `.html_safe` prevents
    # double-escaping it. `render html:` escapes the string otherwise.
    # rubocop:disable Rails/OutputSafety
    render html: body.html_safe, layout: 'application'
    # rubocop:enable Rails/OutputSafety
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
end
