module InvitationControllerConcerns
  extend ActiveSupport::Concern

  included do
    include WorkshopInvitationConcerns
    include InstanceMethods
  end

  module InstanceMethods
    def accept
      user = current_user || @invitation.member
      workshop = @invitation.workshop
      return back_with_message(t('messages.already_rsvped')) if @invitation.attending?

      @invitation.assign_attributes(invitation_params.merge!(attending: true, rsvp_time: Time.zone.now))
      return back_with_message(@invitation.errors.full_messages) unless @invitation.valid?

      if user.has_existing_RSVP_on(workshop.date_and_time)
        return back_with_message(t('messages.invitations.rsvped_to_other_workshop'))
      end

      return back_with_message(t('messages.already_invited')) if attending_or_waitlisted?(workshop, user)

      @workshop = WorkshopPresenter.decorate(@invitation.workshop)
      if available_spaces?(@workshop, @invitation)
        @invitation.update(invitation_params.merge!(attending: true, rsvp_time: Time.zone.now))
        @workshop.send_attending_email(@invitation)

        back_with_message(t('messages.accepted_invitation', name: @invitation.member.name))
      else
        back_with_message(t('messages.no_available_seats'))
      end
    end

    def reject
      @workshop = WorkshopPresenter.decorate(@invitation.workshop)
      if @invitation.workshop.date_and_time - 3.5.hours >= Time.zone.now
        if @invitation.attending.eql? false
          redirect_back(fallback_location: invitation_path(@invitation),
                        notice: t('messages.not_attending_already'))
        else
          begin
            WorkshopInvitation.transaction do
              @invitation.decline!
              promote_from_waitlist(@invitation.workshop, @invitation.role)
            end
            redirect_back(
              fallback_location: invitation_path(@invitation),
              notice: t('messages.rejected_invitation', name: @invitation.member.name)
            )
          rescue ActiveRecord::RecordInvalid
            redirect_back(
              fallback_location: invitation_path(@invitation),
              alert: 'Unable to process cancellation. Please try again.'
            )
          end
        end
      else
        redirect_back(
          fallback_location: invitation_path(@invitation),
          notice: 'You can only change your RSVP status up to 3.5 hours before the workshop'
        )
      end
    end

    private

    def promote_from_waitlist(workshop, role)
      next_spot = WaitingList.next_spot(workshop, role)
      return unless next_spot

      invitation = next_spot.invitation
      next_spot.destroy!
      invitation.accept!(rsvp_time: Time.zone.now, automated_rsvp: true)
      WorkshopPresenter.decorate(workshop).send_attending_email(invitation, true)
    end

    def attending_or_waitlisted?(workshop, user)
      workshop.attendee?(user) || workshop.waitlisted?(user)
    end
  end
end
