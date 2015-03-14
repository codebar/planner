class AuthSessionsController < ApplicationController

  def create
    redirect_to redirect_path
  end

  def destroy
    logout!
    redirect_to root_url
  end
end
