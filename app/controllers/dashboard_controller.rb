class DashboardController < ApplicationController
  def show
    @next_session = Sessions.next
    @next_course = Course.next
    @sponsors = Sponsor.latest
  end

  def code
  end

  def about
  end

  def coaches
  end
end
