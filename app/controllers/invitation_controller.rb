class InvitationController < ApplicationController
  include InvitationControllerConcerns


  private

  def set_invitation
    @invitation = SessionInvitation.find_by_token(params[:id])
  end

  def has_remaining_seats? invitation
    invitation.sessions.host.seats > invitation.sessions.attending_invitations.length
  end
end
