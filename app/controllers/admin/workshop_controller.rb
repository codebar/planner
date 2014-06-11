class Admin::WorkshopController < Admin::ApplicationController

  def index
    @sessions = Sessions.upcoming
  end
end
