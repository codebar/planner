class InvitationController < ApplicationController
  include InvitationControllerConcerns

  def show
    @host_address = AddressDecorator.decorate(@invitation.parent.host.address)
  end

  private

  def set_invitation
    @invitation = SessionInvitation.find_by_token(params[:id])
  end
end
