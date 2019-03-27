class ApplicationController < ActionController::Base
  include Pundit

  rescue_from Exception do |ex|
    Rollbar.error(ex)
    Rails.logger.fatal(ex)
    respond_to do |format|
      format.html { render 'errors/error', layout: false, :status => 500 }
      format.all  { render :nothing => true, :status => 500 }
    end
  end

  rescue_from ActionController::RoutingError, with: :render_not_found
  rescue_from ActiveRecord::RecordNotFound , with: :render_not_found

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from Pundit::AuthorizationNotPerformedError, with: :user_not_authorized

  helper_method :logged_in?
  helper_method :current_user
  helper_method :current_service

  before_action :set_locale

  def render_not_found
    respond_to do |format|
      format.html { render :template => "errors/not_found", layout: false, :status => 404 }
      format.all  { render :nothing => true, :status => 404 }
    end
  end

  protected

  def current_user
    if session.key?(:member_id)
      @current_member ||= Member.find(session[:member_id])
    end
  rescue ActiveRecord::RecordNotFound
    session[:member_id] = nil
  end

  def current_service
    if session.key?(:service_id)
      @current_service ||= Service.find_by(member_id: session[:member_id],
                                           id: session[:service_id])
    end
  rescue ActiveRecord::RecordNotFound
    session[:service_id] = nil
  end

  def current_user?
    !!current_user
  end

  def logged_in?
    current_user?
  end

  def authenticate_member!
    if current_user
      finish_registration
    else
      redirect_to redirect_path
    end
  end

  def finish_registration
    if current_user.requires_additional_details?
      redirect_to step1_member_path unless providing_additional_details?
    end
  end

  def providing_additional_details?
    [edit_member_path, step1_member_path].include? request.path
  end

  def logout!
    @current_member = nil
    reset_session
  end

  helper_method :redirect_path
  def redirect_path
    '/auth/github'
  end

  def authenticate_admin!
    redirect_to root_path, notice: "You can't be here" unless logged_in? && current_user.has_role?(:admin)
  end

  def authenticate_admin_or_organiser!
    redirect_to root_path, notice: "You can't be here" unless manager?
  end

  def manager?
    logged_in? && (current_user.is_admin? || current_user.has_role?(:organiser, :any))
  end

  helper_method :manager?

  def is_verified_coach_or_admin?
    current_user.verified?
  end

  def is_verified_coach_or_organiser?
    current_user.verified_or_organiser?
  end

  helper_method :is_verified_coach_or_admin?
  helper_method :is_verified_coach_or_organiser?

  def is_logged_in?
    unless logged_in?
      flash[:notice] = t('notifications.not_logged_in')
      redirect_to root_path
    end
  end

  def has_access?
    is_logged_in?
  end

  private

  def set_locale
    store_locale_to_cookie(params[:locale]) if locale
    I18n.locale = cookies[:locale] || I18n.default_locale
  end

  def user_not_authorized
    redirect_to(user_path, notice: 'You are not authorized to perform this action.')
  end

  def user_path
    request.referrer || root_path
  end

  def jobs_pending_approval
    @jobs_pending_approval ||= Job.where(approved: false, submitted: true).count
  end

  def chapters
    @chapters ||= Chapter.all
  end

  helper_method :jobs_pending_approval, :chapters

  def upcoming_workshops
    Workshop.upcoming
  end

  helper_method :upcoming_workshops

  def redirect_back(fallback_location:, **args)
    if referer = request.headers["Referer"]
      redirect_to referer, **args
    else
      redirect_to fallback_location, **args
    end
  end

  def store_locale_to_cookie(locale)
    cookies[:locale] = { value: locale,
                         expires: Time.zone.now + 36_000 }
  end

  def locale
    params[:locale] if params[:locale] && I18n.available_locales.include?(params[:locale].to_sym)
  end
end
