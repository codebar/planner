class Admin::InvitationController < Admin::ApplicationController
  include  Admin::WorkshopConcerns

  # event invitations

  def verify
    invitation = Invitation.find_by_token(params[:invitation_id])
    invitation.update_attributes(verified: true, verified_by: current_user)

    EventInvitationMailer.attending(invitation.event, invitation.member, invitation).deliver_now

    redirect_to :back, notice: "You have verified #{invitation.member.full_name}'s spot at the event!"
  end

  def cancel
    invitation = Invitation.find_by_token(params[:invitation_id])
    invitation.update_attribute(:attending, false)

    redirect_to :back, notice: "You have cancelled #{invitation.member.full_name}'s attendance."
  end

end
