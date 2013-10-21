class InvitationController < ApplicationController

  def accept
    @invitation = Invitation.find_by_token(params[:id])
    @invitation.update_attribute(:attending, true)

    redirect_to root_path, notice: "Thanks for getting back to us #{@invitation.member.name}. See you at the meeting!"
  end
end
