class Coach::ApplicationController < ApplicationController
  before_action :has_access?

  def has_access?
    redirect_to root_path unless can_view_feedback?
  end

  private

  def can_view_feedback?
    logged_in? and (is_verified_coach_or_admin? or is_verified_coach_or_organiser?)
  end
end
