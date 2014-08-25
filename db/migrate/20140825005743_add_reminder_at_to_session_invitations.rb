class AddReminderAtToSessionInvitations < ActiveRecord::Migration
  def change
    add_column :session_invitations, :reminded_at, :datetime, default: nil
  end
end
