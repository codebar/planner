class AuthSessionsController < ApplicationController

  def create
    session[:role] = params["role"]
    redirect_to redirect_path
  end

  def destroy
    logout!
    redirect_to root_url
  end
end
