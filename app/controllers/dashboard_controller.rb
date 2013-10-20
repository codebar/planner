class DashboardController < ApplicationController
  def show
    @sessions = Sessions.upcoming
  end

  def about
  end
end
