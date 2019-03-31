class Admin::InvitationController < Admin::ApplicationController
  include Admin::WorkshopConcerns

  # event invitations

  def update
    invitation = Invitation.find_by(token: params[:invitation][:id])
    invitation.update(attending: true, verified: true, verified_by: current_user)

    EventInvitationMailer.attending(invitation.event, invitation.member, invitation).deliver_now

    flash[:notice] = "You have verified #{invitation.member.full_name}'s spot at the event!"
    redirect_back(fallback_location: root_path)
  end

  def verify
    invitation = Invitation.find_by(token: params[:invitation_id])
    invitation.update(verified: true, verified_by_id: current_user.id)

    EventInvitationMailer.attending(invitation.event, invitation.member, invitation).deliver_now

    flash[:notice] = "You have verified #{invitation.member.full_name}'s spot at the event!"
    redirect_back(fallback_location: root_path)
  end

  def cancel
    invitation = Invitation.find_by(token: params[:invitation_id])
    invitation.update(attending: false)

    flash[:notice] = "You have cancelled #{invitation.member.full_name}'s attendance."
    redirect_back(fallback_location: root_path)
  end
end
