class AddRsvpOpensAtToWorkshops < ActiveRecord::Migration
  def change
    rename_column :workshops, :rsvp_open_time, :rsvp_opens_at
    remove_column :workshops, :rsvp_open_date, :datetime
    rename_column :workshops, :rsvp_close_time, :rsvp_closes_at
  end
end
