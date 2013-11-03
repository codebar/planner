class RenameInvitationsToSessionInvitations < ActiveRecord::Migration
  def change
    rename_table :invitations, :session_invitations
  end
end
