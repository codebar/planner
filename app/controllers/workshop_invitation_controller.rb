class WorkshopInvitationController < ApplicationController
  include WorkshopInvitationConcerns
  include WaitlistPromotionConcerns

  # NOTE: This controller handles workshop invitations (WorkshopInvitation model).
  # It provides accept/reject RSVP actions for workshop attendees via token-based links.
  # Routes: /invitation/:token (legacy) and /workshop_invitation/:token

  # The invitation token in the URL is the authenticator for these actions;
  # CSRF is redundant and fails when browsers withhold the session cookie
  # (e.g. Safari/WebKit ITP on cross-site navigation). Same rationale as
  # FeedbackController#submit (PR #2641, Rollbar #535).
  skip_forgery_protection only: %i[update accept reject]

  def show
    @announcements = @invitation.member.announcements.active
    @tutorial_titles = Tutorial.all_titles

    @workshop = WorkshopPresenter.decorate(@invitation.workshop)

    render plain: @workshop.attendees_csv if request.format.csv?
  end

  def update
    if @invitation.update(invitation_params)
      back_with_message(t('messages.invitations.updated_details'))
    else
      back_with_message(@invitation.errors.full_messages)
    end
  end

  # Inline accept from InvitationControllerConcerns
  def accept
    user = current_user || @invitation.member
    workshop = @invitation.workshop
    return back_with_message(t('messages.already_rsvped')) if @invitation.attending?
    return back_with_message(t('messages.invitations.closed')) unless workshop.rsvp_available?

    if user.existing_rsvp_on?(workshop.date_and_time)
      return back_with_message(t('messages.invitations.rsvped_to_other_workshop'))
    end

    return back_with_message(t('messages.already_invited')) if attending_or_waitlisted?(workshop, user)

    @workshop = WorkshopPresenter.decorate(@invitation.workshop)
    return back_with_message(t('messages.no_available_seats')) unless available_spaces?(@workshop, @invitation)

    if @invitation.update(invitation_params.merge!(attending: true, rsvp_time: Time.zone.now))
      MemberActivityRecorder.record(actor: @invitation.member, key: 'workshop_invitation.rsvp',
                                    trackable: @invitation)
      @workshop.send_attending_email(@invitation)
      back_with_message(t('messages.accepted_invitation', name: @invitation.member.name))
    else
      back_with_message(@invitation.errors.full_messages)
    end
  end

  # Inline reject from InvitationControllerConcerns
  def reject
    @workshop = WorkshopPresenter.decorate(@invitation.workshop)
    if @invitation.workshop.cancellations_open?
      if @invitation.attending.eql? false
        redirect_back(fallback_location: invitation_path(@invitation),
                      notice: t('messages.not_attending_already'))
      else
        freed_seat = release_seat
        MemberActivityRecorder.record(actor: @invitation.member, key: 'workshop_invitation.rejected',
                                      trackable: @invitation)

        promote_next_waitlist_member if freed_seat

        redirect_back(
          fallback_location: invitation_path(@invitation),
          notice: t('messages.rejected_invitation', name: @invitation.member.name)
        )
      end
    else
      redirect_back(
        fallback_location: invitation_path(@invitation),
        notice: 'You can only change your RSVP status up to 3.5 hours before the workshop'
      )
    end
  end

  private

  def invitation_params
    if params.key?(:workshop_invitation)
      params.require(:workshop_invitation).permit(:tutorial, :note)
    else
      {}
    end
  end

  def available_spaces?(workshop, invitation)
    (invitation.role.eql?('Student') && workshop.event_student_spaces?) ||
      (invitation.role.eql?('Coach') && workshop.event_coach_spaces?)
  end

  # Inline from InvitationControllerConcerns
  def attending_or_waitlisted?(workshop, user)
    workshop.attendee?(user) || workshop.waitlisted?(user)
  end

  def token
    params[:id]
  end
end
