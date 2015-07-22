class ApplicationController < ActionController::Base
  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from Pundit::AuthorizationNotPerformedError, with: :user_not_authorized

  helper_method :logged_in?
  helper_method :current_user
  helper_method :current_service

  protected

  def current_user
    if session.has_key?(:member_id)
      @current_member ||= Member.find(session[:member_id])
    end
  rescue ActiveRecord::RecordNotFound
    session[:member_id] = nil
  end

  def current_service
    if session.has_key?(:service_id)
      @current_service ||= Service.where(member_id: session[:member_id],
                                         id: session[:service_id]).first
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
    "/auth/github"
  end

  def authenticate_admin!
    redirect_to root_path, notice: "You can't be here" unless logged_in? and current_user.has_role?(:admin)
  end

  def manager?
    logged_in? and (current_user.is_admin? or current_user.is_organiser?)
  end

  helper_method :manager?

  def is_verified_coach_or_admin?
    current_user.verified?
  end

  helper_method :is_verified_coach_or_admin?

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

  def user_not_authorized
    redirect_to(user_path, notice: "You are not authorized to perform this action.")
  end

  def user_path
    request.referrer or root_path
  end

  def jobs_pending_approval
    @jobs_pending_approval ||= Job.where(approved: false, submitted: true).count
  end

  def chapters
    @chapters ||= Chapter.all
  end

  helper_method :jobs_pending_approval, :chapters

  def upcoming_workshops
    Sessions.upcoming
  end

  helper_method :upcoming_workshops
end
