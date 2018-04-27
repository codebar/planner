class RenameTableSessionInvitationsToWorkshopInvitations < ActiveRecord::Migration
  def change
    rename_table :session_invitations, :workshop_invitations
  end
end
