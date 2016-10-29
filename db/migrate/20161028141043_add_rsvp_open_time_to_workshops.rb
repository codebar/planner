class AddRsvpOpenTimeToWorkshops < ActiveRecord::Migration
  def change
    add_column :workshops, :rsvp_open_time, :datetime
    add_column :workshops, :rsvp_open_date, :datetime
  end
end
