class RenameInvitationsToSessionInvitations < ActiveRecord::Migration[4.2]
  def change
    rename_table :invitations, :session_invitations
  end
end
