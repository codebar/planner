class RemoveInvitesSentFromMeetings < ActiveRecord::Migration[8.1]
  def change
    safety_assured { remove_column :meetings, :invites_sent, :boolean, default: false }
  end
end
