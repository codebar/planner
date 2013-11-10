class DashboardController < ApplicationController
  def show
    @sessions = Sessions.upcoming
  end

  def code
  end

  def about
  end

  def coaches
  end
end
