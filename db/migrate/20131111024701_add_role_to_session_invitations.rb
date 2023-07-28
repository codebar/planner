class AddRoleToSessionInvitations < ActiveRecord::Migration[4.2]
  def change
    add_column :session_invitations, :role, :string
  end
end
