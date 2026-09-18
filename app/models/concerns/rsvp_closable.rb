module RsvpClosable
  extend ActiveSupport::Concern

  DEFAULT_RSVPS_CLOSE_OFFSET = 3.5.hours

  included do
    include InstanceMethods
  end

  module InstanceMethods
    # The time after which new RSVPs are no longer accepted. Models with an
    # explicit close time override this to prefer the stored value.
    def effective_rsvp_closes_at
      date_and_time - DEFAULT_RSVPS_CLOSE_OFFSET
    end

    def rsvp_available?
      effective_rsvp_closes_at.future?
    end
  end
end
