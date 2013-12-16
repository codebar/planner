class Admin::PortalController < Admin::ApplicationController

  def index
    @sessions = Sessions.upcoming
  end
end
