class CreateChaptersEvents < ActiveRecord::Migration[4.2]
  def change
    create_table :chapters_events do |t|
      t.integer :chapter_id, index: true
      t.integer :event_id, index: true
    end
  end
end
