class Admin::InvitationsController < Admin::ApplicationController

  def update
    @workshop = Sessions.find(params[:workshop_id])
    authorize @workshop

    @invitation = @workshop.invitations.find(params[:workshop][:invitations])
    @invitation.update_attribute(:attending, true)

    waiting_listed = WaitingList.where(invitation: @invitation).first
    waiting_listed.delete if waiting_listed

    SessionInvitationMailer.attending(@workshop, @invitation.member, @invitation).deliver

    redirect_to :back, notice: "You have RSVPed #{@invitation.member.full_name} to the workshop. "
  end
end
