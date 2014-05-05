class InvitationsController < ApplicationController
  before_action :is_member?

  def index
    @upcoming_session = Sessions.next

    if current_member.is_student?
      @upcoming_student = SessionInvitation.to_students.where(member: current_member).joins(:sessions).where("date_and_time >= ?", DateTime.now)
      @upcoming_student += CourseInvitation.where(member: current_member).joins(:course).where("date_and_time >= ?", DateTime.now)
      @attended = SessionInvitation.to_students.where(member: current_member).attended
    end

    if current_member.is_coach?
      @upcoming_coach = SessionInvitation.to_coaches.where(member: current_member).joins(:sessions).where("date_and_time >= ?", DateTime.now)
      @coached = SessionInvitation.to_coaches.where(member: current_member).attended
    end

  end
end
