class DashboardController < ApplicationController
  before_action :is_logged_in?, only: %i[dashboard]
  skip_before_action :accept_terms, except: %i[dashboard show]

  helper_method :year_param

  def show
    @chapters = Chapter.active.all.order(:created_at)
    @user = current_user ? MemberPresenter.new(current_user) : nil
    @upcoming_workshops = DashboardService.new(current_user).upcoming_workshops
    @testimonials = Testimonial.order(Arel.sql('RANDOM()')).limit(5).includes(:member)
  end

  def dashboard
    @user = MemberPresenter.new(current_user)
    @ordered_events = DashboardService.new(current_user).ordered_events
    @announcements = current_user.announcements.active
  end

  def code; end

  def faq; end

  def about; end

  def wall_of_fame
    @coaches_count = DashboardService.new.coaches_count
    @coaches = DashboardService.new.coaches(page, year_param)
  end

  def participant_guide; end

  private

  def page
    params.permit(:page)[:page]
  end

  def year_param
    params.permit(:year)[:year] || Time.zone.today.year
  end

end

