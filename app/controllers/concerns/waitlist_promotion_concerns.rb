# Shared by controllers that cancel a workshop invitation and fill the freed
# seat from the waiting list. Requires @invitation and the decorated
# @workshop presenter to be set by the including controller.
module WaitlistPromotionConcerns
  extend ActiveSupport::Concern

  included do
    include InstanceMethods
  end

  module InstanceMethods
    private

    # Releases the invitation's seat under a row lock so two concurrent
    # cancellation requests cannot each believe they freed a seat. Returns true
    # only when this request moved a seat-holder to not attending.
    def release_seat(additional_attributes = {})
      @invitation.with_lock do
        was_attending = @invitation.attending.eql?(true)
        @invitation.update!(additional_attributes.merge(attending: false))
        was_attending
      end
    end

    def promote_next_waitlist_member
      promoted = WaitingList.promote_next(@invitation.workshop, @invitation.role)
      @workshop.send_attending_email(promoted, true) if promoted
    end
  end
end
