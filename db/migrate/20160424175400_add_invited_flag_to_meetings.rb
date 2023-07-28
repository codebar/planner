class AddInvitedFlagToMeetings < ActiveRecord::Migration[4.2]
  def change
    add_column :meetings, :invites_sent, :boolean, default: false
  end
end
