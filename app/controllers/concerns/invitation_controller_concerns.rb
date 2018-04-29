module InvitationControllerConcerns
  extend ActiveSupport::Concern

  included do
    before_action :set_invitation

    include InstanceMethods
  end

  module InstanceMethods
    def accept
      if @invitation.attending?
        redirect_to :back, notice: t('messages.already_rsvped')
      end

      user = current_user || @invitation.member

      if user.has_existing_RSVP_on(@invitation.workshop.date_and_time)
        return redirect_to :back, notice: t('messages.invitations.rsvped_to_other_workshop')
      end

      @workshop = WorkshopPresenter.new(@invitation.workshop)
      if (@invitation.for_student? && @workshop.student_spaces?) || (@invitation.for_coach? && @workshop.coach_spaces?)
        @invitation.update_attributes(attending: true, rsvp_time: Time.zone.now)
        @invitation.waiting_list.destroy if @invitation.waiting_list.present?
        WorkshopInvitationMailer.attending(@invitation.workshop, @invitation.member, @invitation).deliver_now

        redirect_to :back, notice: t('messages.accepted_invitation',
                                     name: @invitation.member.name)

      else
        redirect_to :back, notice: t('messages.no_available_seats', email: @invitation.workshop.chapter.email)
      end
    end

    def reject
      if @invitation.parent.date_and_time - 3.5.hours >= Time.zone.now

        if @invitation.attending.eql? false
          redirect_to :back, notice: t('messages.not_attending_already')
        else
          @invitation.update_attribute(:attending, false)

          next_spot = WaitingList.next_spot(@invitation.workshop, @invitation.role)

          if next_spot.present?
            invitation = next_spot.invitation
            next_spot.destroy
            invitation.update_attribute(:attending, true)
            WorkshopInvitationMailer.attending(invitation.workshop, invitation.member, invitation, true).deliver_now
          end

          redirect_to :back, notice: t('messages.rejected_invitation', name: @invitation.member.name)
        end
      else
        redirect_to :back, notice: 'You can only change your RSVP status up to 3.5 hours before the workshop'
      end
    end
  end
end
