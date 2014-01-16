class InvitationController < ApplicationController
  include InvitationControllerConcerns

  def show
    @host_address = AddressDecorator.decorate(@invitation.parent.host.address)
  end

  private

  def set_invitation
    @invitation = SessionInvitation.find_by_token(params[:id])
  end

  def has_remaining_seats? invitation
    invitation.sessions.host.seats > invitation.sessions.attending_students.length
  end
end
