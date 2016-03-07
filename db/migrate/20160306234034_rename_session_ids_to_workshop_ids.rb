class RenameSessionIdsToWorkshopIds < ActiveRecord::Migration
  def change
    rename_column :feedback_requests, :sessions_id, :workshop_id
    rename_column :session_invitations, :sessions_id, :workshop_id
    rename_column :sponsor_sessions, :sessions_id, :workshop_id
    rename_column :tutorials, :sessions_id, :workshop_id
  end
end
