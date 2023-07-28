class AddRsvpCloseTimeToSessions < ActiveRecord::Migration[4.2]
  def change
    add_column :sessions, :rsvp_close_time, :datetime
  end
end
