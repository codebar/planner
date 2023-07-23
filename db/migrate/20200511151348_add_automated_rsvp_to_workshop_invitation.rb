class AddAutomatedRsvpToWorkshopInvitation < ActiveRecord::Migration[4.2]
  def change
    add_column :workshop_invitations, :automated_rsvp, :boolean
  end
end
