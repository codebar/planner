class WaitingListsController < ApplicationController
  def create
    invitation.update_attribute(:note, note) if note.present?
    WaitingList.add(invitation, auto_rsvp)
    message = auto_rsvp ? 'You have been added to the waiting list' :
                          'We will send you an email if any spots become available'
    redirect_to invitation_path(invitation), notice: message
  end

  def destroy
    WaitingList.find_by(invitation_id: invitation.id).destroy

    redirect_to invitation_path(invitation), notice: 'You have been removed from the waiting list'
  end

  private

  def invitation_token
    params.permit(:invitation_id)[:invitation_id]
  end

  def auto_rsvp
    true
  end

  def note
    params.key?(:invitation) ? params[:invitation][:note] : params[:note]
  end

  def invitation
    @invitation ||= WorkshopInvitation.find_by(token: invitation_token)
  end
end
