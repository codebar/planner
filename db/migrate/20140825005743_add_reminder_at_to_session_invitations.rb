class AddReminderAtToSessionInvitations < ActiveRecord::Migration[4.2]
  def change
    add_column :session_invitations, :reminded_at, :datetime, default: nil
  end
end
