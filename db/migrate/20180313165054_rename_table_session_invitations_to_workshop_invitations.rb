class RenameTableSessionInvitationsToWorkshopInvitations < ActiveRecord::Migration[4.2]
  def change
    rename_table :session_invitations, :workshop_invitations
  end
end
