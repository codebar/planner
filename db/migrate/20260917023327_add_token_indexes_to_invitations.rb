class AddTokenIndexesToInvitations < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    add_index :invitations, :token, unique: true, algorithm: :concurrently
    add_index :meeting_invitations, :token, unique: true, algorithm: :concurrently
  end

  def down
    remove_index :invitations, :token
    remove_index :meeting_invitations, :token
  end
end
