  # frozen_string_literal: true
  module Managers
    class AttendanceManager
      attr_reader :workshop, :invitation
      def initialize(workshop_id, invitation_id, current_user)
        @workshop = WorkshopPresenter.decorate(Workshop.find(workshop_id))
        @invitation = @workshop.invitations.find_by(token: invitation_id)
        @current_user = current_user
      end

      def update(attending:, attended:)
        return update_to_attended if attended

        result = attending ? update_to_attending : update_to_not_attending
        message, error = result.values_at(:message, :error)

        unless error
          waiting_listed = WaitingList.find_by(invitation: @invitation)
          waiting_listed&.destroy!
        end

        message
      end

      private
      def update_to_attended
        @invitation.update(attended: true)

        "You have verified #{@invitation.member.full_name}’s attendance."
      end

      def update_to_attending
        update_successful = @invitation.update(
          attending: true,
          rsvp_time: Time.zone.now,
          automated_rsvp: true,
          last_overridden_by_id: @current_user.id
        )

        {
          message: update_successful ? attending_successful : attending_failed,
          error: !update_successful
        }
      end

      def update_to_not_attending
        @invitation.update!(attending: false, last_overridden_by_id: @current_user.id)

        {
          message: "You have removed #{@invitation.member.full_name} from the workshop.",
          error: false
        }
      end

      def attending_successful
        @workshop.send_attending_email(@invitation) if @workshop.future?

        "You have added #{@invitation.member.full_name} to the workshop as a #{@invitation.role}."
      end

      def attending_failed
        "Error adding #{@invitation.member.full_name} as a #{@invitation.role}. "\
          "#{@invitation.errors.full_messages.to_sentence}."
      end
    end
  end
