class AddRsvpTimeToSessionInvitation < ActiveRecord::Migration[4.2]
  def change
    add_column :session_invitations, :rsvp_time, :datetime
  end
end
