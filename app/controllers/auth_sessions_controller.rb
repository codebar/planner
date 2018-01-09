class AuthSessionsController < ApplicationController
  def create
    cookies[:member_type] = params[:member_type]
    redirect_to redirect_path
  end

  def destroy
    logout!
    redirect_to root_url
  end
end
