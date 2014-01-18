class Admin::InvitationController < Admin::ApplicationController

  def attended
    invitation = SessionInvitation.find_by_token(params[:invitation_id])

    invitation.update_attribute(:attended,params[:attended])
    redirect_to :back, notice: "You have verified #{invitation.member.full_name}'s attendance!"
  end
end
