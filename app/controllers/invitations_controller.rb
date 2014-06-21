class InvitationsController < ApplicationController
  before_action :is_member?

  def index
    @upcoming_session = Sessions.next

    @upcoming_invitations = SessionInvitation.where(member: current_user).joins(:sessions).where("date_and_time >= ?", DateTime.now)
    @upcoming_invitations += CourseInvitation.where(member: current_user).joins(:course).where("date_and_time >= ?", DateTime.now)

    @attended_invitations = SessionInvitation.where(member: current_user).attended
  end
end
