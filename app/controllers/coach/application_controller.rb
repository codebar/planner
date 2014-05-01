class Coach::ApplicationController < ApplicationController
  before_action :has_access?

  def has_access?
    redirect_to root_path unless logged_in? and is_verified_coach_or_admin?
  end
end
