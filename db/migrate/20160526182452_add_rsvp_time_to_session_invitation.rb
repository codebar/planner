class AddRsvpTimeToSessionInvitation < ActiveRecord::Migration
  def change
    add_column :session_invitations, :rsvp_time, :datetime
  end
end
