class CreateMeetingTalks < ActiveRecord::Migration
  def change
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
