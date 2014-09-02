class WaitingListsController < ApplicationController

  def create
    WaitingList.add(invitation, auto_rsvp)
    message = auto_rsvp.eql?(true) ? "You have been added to the Waiting list" :
                          "We will send you an email if any spots become available"
    redirect_to invitation_path(invitation), notice: message
  end

  def destroy
    WaitingList.find_by_invitation_id(invitation.id).delete

    redirect_to invitation_path(invitation), notice: "You have been removed from the waiting list"
  end

  private

  def invitation_token
    params.permit(:invitation_id)[:invitation_id]
  end

  def auto_rsvp
    params[:auto_rsvp] || true
  end

  def invitation
    @invitation ||= SessionInvitation.find_by_token(invitation_token)
  end
end
