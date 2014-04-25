class Admin::InvitationController < Admin::ApplicationController

  def attended
    invitation = SessionInvitation.find_by_token(params[:invitation_id])

    invitation.update_attribute(:attended,params[:attended])
    redirect_to :back, notice: "You have verified #{invitation.member.full_name}'s attendance!"
  end

  def not_attending
    invitation = SessionInvitation.find_by_token(params[:invitation_id])

    invitation.update_attribute(:attending, false)
    redirect_to :back, notice: "You have changed #{invitation.member.full_name}'s attending status!"
  end
end
