class AddAttendedToMeetingInvitation < ActiveRecord::Migration[4.2]
  def change
    add_column :meeting_invitations, :attended, :boolean, default: false
  end
end
