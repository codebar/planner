class AddRsvpCloseTimeToSessions < ActiveRecord::Migration
  def change
    add_column :sessions, :rsvp_close_time, :datetime
  end
end
