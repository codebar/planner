class Admin::MeetingInvitationsController < Admin::ApplicationController
  before_action :set_invitation

  def update
    status = params[:attendance_status]
    @invitation.update_attribute(:attending, status)

    redirect_to [:admin, @invitation.meeting]
  end

  private

  def set_invitation
    @invitation = MeetingInvitation.find_by_token(params[:id])
  end
end