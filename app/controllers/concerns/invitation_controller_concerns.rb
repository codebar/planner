module InvitationControllerConcerns
  extend ActiveSupport::Concern

  included do
    before_action :set_invitation

    include InstanceMethods
  end

  module InstanceMethods

    def accept
      if @invitation.attending.eql? true
        redirect_to :back, notice: t("messages.already_rsvped")
      end

      if @invitation.student_spaces? or @invitation.coach_spaces?
        @invitation.update_attribute(:attending, true)
        @invitation.waiting_list.delete  if @invitation.waiting_list.present?
        SessionInvitationMailer.attending(@invitation.sessions, @invitation.member, @invitation).deliver

        redirect_to :back, notice: t("messages.accepted_invitation",
                                     name: @invitation.member.name)

      else
        redirect_to :back, notice: t("messages.no_available_seats", email: @invitation.sessions.chapter.email)
      end
    end

    def reject
      if @invitation.parent.date_and_time-3.5.hours >= DateTime.now

        if @invitation.attending.eql? false
          redirect_to :back, notice: t("messages.not_attending_already")
        else
          @invitation.update_attribute(:attending, false)

          next_spot = WaitingList.next_spot(@invitation.sessions, @invitation.role)

          if next_spot.present?
            invitation = next_spot.invitation
            next_spot.delete
            invitation.update_attribute(:attending, true)
            SessionInvitationMailer.attending(invitation.sessions, invitation.member, invitation, true).deliver
          end

          redirect_to :back, notice: t("messages.rejected_invitation", name: @invitation.member.name)
        end
      else
        redirect_to :back, notice: "You can only change your RSVP status up to 3.5 hours before the workshop"
      end
    end
  end
end
