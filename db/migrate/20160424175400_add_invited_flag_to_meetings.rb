class AddInvitedFlagToMeetings < ActiveRecord::Migration
  def change
    add_column :meetings, :invites_sent, :boolean, default: false
  end
end
