class AuthSessionsController < ApplicationController
  skip_before_action :current_user_complete_sign_up!

  def create
    cookies[:member_type] = params[:member_type]
    redirect_to redirect_path
  end

  def destroy
    logout!
    redirect_to root_url
  end
end
