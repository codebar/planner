class SessionsController < ApplicationController

  def index
    @sessions = Sessions.all
  end

end
