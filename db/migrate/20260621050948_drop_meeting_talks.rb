class DropMeetingTalks < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      drop_table :meeting_talks
    end
  end

  def down
    create_table :meeting_talks do |t|
      t.references :meeting, index: true
      t.string :title
      t.string :description
      t.text :abstract
      t.integer :speaker_id, index: true
      t.timestamps
    end
  end
end
