class WaitingListsController < ApplicationController
  include WorkshopInvitationConcerns

  # The invitation token in the URL is the authenticator for these actions;
  # CSRF is redundant and fails when browsers withhold the session cookie
  # (e.g. Safari/WebKit ITP on cross-site navigation). Same rationale as
  # FeedbackController#submit (PR #2641, Rollbar #535).
  skip_forgery_protection only: %i[create destroy]

  def create
    @invitation.assign_attributes(invitation_params)

    return back_with_message(@invitation.errors.full_messages) unless @invitation.valid?(:waitinglist)

    @invitation.save && WaitingList.add(@invitation, auto_rsvp)

    message = if auto_rsvp
      'You have been added to the waiting list'
    else
      'We will send you an email if any spots become available'
    end

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
