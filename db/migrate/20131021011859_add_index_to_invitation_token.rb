class AddIndexToInvitationToken < ActiveRecord::Migration[4.2]
  def change
    add_index :invitations, :token, unique: true
  end
end
