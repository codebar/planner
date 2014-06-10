class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :logged_in?
  helper_method :current_member
  helper_method :current_service

  protected

  def current_member
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

  def current_member?
    !!current_member
  end

  def logged_in?
    current_member?
  end

  def authenticate_member!
    if session.has_key?(:member_id)
      current_member
      finish_registration
    else
      redirect_to redirect_path
    end
  end

  def finish_registration
    if current_member.requires_additional_details?
      flash[:notice] = "We need to know a little more about you. Please finish the registration form below."
      redirect_to edit_member_path
    end
  end

  def logout!
    @current_member = nil
    reset_session
  end

  def redirect_path
    "/auth/github"
  end

  def admin?
    current_member? and current_member.is_admin?
  end

  helper_method :admin?

  def is_verified_coach_or_admin?
    current_member and (current_member.is_admin? or (current_member.is_coach? and current_member.verified?))
  end

  helper_method :is_verified_coach_or_admin?

  def is_member?
    unless logged_in?
      flash[:notice] = "Only authorised members can access that link. If you are a member please sign in"
      redirect_to root_path
    end
  end

  def has_access?
    redirect_to root_path unless logged_in?
  end
end
