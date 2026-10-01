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
    options = past_year? ? {} : { expires_in: 24.hours }
    body = Rails.cache.fetch(wall_of_fame_cache_key, **options) { render_wall_of_fame_body }
    # The layout renders fresh so asset URLs and meta tags are never stale;
    # bump v2 when the wall_of_fame view or its partials change.
    # Past-year entries carry no explicit expires_in and age out via Solid
    # Cache's max_age (2 weeks by default); current-year entries expire daily.
    # The cached body is fully rendered template output; `.html_safe` prevents
    # double-escaping it. `render html:` escapes the string otherwise.
    # rubocop:disable Rails/OutputSafety
    render html: body.html_safe, layout: 'application'
    # rubocop:enable Rails/OutputSafety
  end

  def participant_guide; end

  private

  def past_year?
    (2013...Time.zone.today.year).cover?(year_param)
  end

  def wall_of_fame_cache_key
    # Match pagy's page coercion so the cache key and the rendered page always
    # agree, and arbitrary strings cannot expand the key space.
    page = [params[:page].to_s.to_i, 1].max
    date_segment = past_year? ? nil : "#{Time.zone.today}/"
    "coaches/wall_of_fame/v2/#{date_segment}#{year_param}/#{page}/#{I18n.locale}"
  end

  def render_wall_of_fame_body
    @coaches_count = WorkshopInvitation.to_coaches.attended.distinct.count(:member_id)
    coaches = Member.where(id: top_coach_query
                               .year(year_param))
                    .includes(:skills)
    # pagy copies every request param into pagination links; keep only the
    # year the links must preserve so the filling request's junk params are
    # not frozen into the cached body.
    @pagy, @coaches = pagy(coaches, querify: ->(params) { params.keep_if { |k, _| %w[year page].include?(k) } })
    render_to_string(layout: false)
  end

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
