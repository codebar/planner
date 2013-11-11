class AddRoleToSessionInvitations < ActiveRecord::Migration
  def change
    add_column :session_invitations, :role, :string
  end
end
