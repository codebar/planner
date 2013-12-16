module PortalHelper

  def attendance_status(invitation)
    invitation.attending ? "Attending" : "RSVP"
  end
end
