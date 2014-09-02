module InvitationControllerConcerns
  extend ActiveSupport::Concern

  included do
    before_action :set_invitation

    include InstanceMethods

    helper_method :available_student_slots?, :more_coaches_needed?
  end

  module InstanceMethods

    def accept
      if @invitation.attending.eql? true
        redirect_to :back, notice: t("messages.already_rsvped")
      end

      if available_student_slots?(@invitation) or more_coaches_needed?(@invitation)
        @invitation.update_attribute(:attending, true)
        SessionInvitationMailer.attending(@invitation.sessions, @invitation.member, @invitation).deliver

        redirect_to :back, notice: t("messages.accepted_invitation",
                                     name: @invitation.member.name)

      else
        redirect_to :back, notice: t("messages.no_available_seats", email: @invitation.sessions.chapter.email)
      end
    end

    def reject
      if @invitation.parent.date_and_time-6.hours >= DateTime.now

        if @invitation.attending.eql? false
          redirect_to :back, notice: t("messages.not_attending_already")
        else
          @invitation.update_attribute(:attending, false)

          next_spot = WaitingList.next_spot(@invitation.role, @invitation.sessions)

          if next_spot.exists?
            invitation = next_spot.invitation
            invitation.update_attribute(:attending, true)
            SessionInvitationMailer.attending(invitation.sessions, invitation.member, invitation, true).deliver
          end

          redirect_to :back, notice: t("messages.rejected_invitation", name: @invitation.member.name)
        end
      else
        redirect_to :back, notice: "You can only change your RSVP status up to 24 hours before the session"
      end
    end

    def more_coaches_needed?(invitation)
      invitation.role.eql?("Coach") and invitation.sessions.host.coach_spots > invitation.sessions.attending_coaches.length
    end

    def available_student_slots?(invitation)
      invitation.role.eql?("Student") and invitation.sessions.host.seats > invitation.sessions.attending_students.length
    end
  end
end
