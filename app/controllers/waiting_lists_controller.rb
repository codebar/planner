class WaitingListsController < ApplicationController
  include WorkshopInvitationConcerns

  def create
    @invitation.assign_attributes(invitation_params)
    return back_with_message(@invitatiaon.errors.full_messages) unless @invitation.valid?

    @invitation.save && WaitingList.add(@invitation, auto_rsvp)
    message = auto_rsvp ? 'You have been added to the waiting list' :
      'We will send you an email if any spots become available'
    back_with_message(message)
  end

  def destroy
    WaitingList.find_by(invitation_id: @invitation.id).destroy

    redirect_to invitation_path(@invitation), notice: 'You have been removed from the waiting list'
  end

  private

  def token
    params.permit(:invitation_id)[:invitation_id]
  end

  def auto_rsvp
    true
  end
end
