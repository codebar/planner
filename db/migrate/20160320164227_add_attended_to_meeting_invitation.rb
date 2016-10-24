class AddAttendedToMeetingInvitation < ActiveRecord::Migration
  def change
    add_column :meeting_invitations, :attended, :boolean, default: false
  end
end
