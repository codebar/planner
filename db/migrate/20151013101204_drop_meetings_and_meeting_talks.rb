class DropMeetingsAndMeetingTalks < ActiveRecord::Migration
  def change
    drop_table :meeting_talks
    drop_table :meetings
  end
end
