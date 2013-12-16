class PortalController < ApplicationController
  before_action :logged_in?

  def index
    if current_member.is_student?
      @upcoming = SessionInvitation.to_students.where(member: current_member).joins(:sessions).where("date_and_time >= ?", DateTime.now)
      @attended = SessionInvitation.to_students.where(member: current_member).attended
    end

    if current_member.is_coach?
      @upcoming_sessions = Sessions.upcoming
      @coached = SessionInvitation.to_coaches.where(member: current_member).attended
    end
  end
end
