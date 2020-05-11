class AddAutomatedRsvpToWorkshopInvitation < ActiveRecord::Migration
  def change
    add_column :workshop_invitations, :automated_rsvp, :boolean
  end
end
