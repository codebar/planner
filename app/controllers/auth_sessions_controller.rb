class AuthSessionsController < ApplicationController

  def create
    session[:role] = params["role"]
    redirect_to "/auth/github"
  end

  def destroy
    logout!
    redirect_to root_url
  end
end
