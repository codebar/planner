class InvitationsController < ApplicationController
  before_action :is_member?

  def index
    @upcoming_session = Sessions.next

    @upcoming_student = SessionInvitation.to_students.where(member: current_user).joins(:sessions).where("date_and_time >= ?", DateTime.now)
    @upcoming_student += CourseInvitation.where(member: current_user).joins(:course).where("date_and_time >= ?", DateTime.now)
    @attended = SessionInvitation.to_students.where(member: current_user).attended
    @upcoming_coach = SessionInvitation.to_coaches.where(member: current_user).joins(:sessions).where("date_and_time >= ?", DateTime.now)
    @coached = SessionInvitation.to_coaches.where(member: current_user).attended

  end
end
