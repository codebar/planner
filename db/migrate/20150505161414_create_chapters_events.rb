class CreateChaptersEvents < ActiveRecord::Migration
  def change
    create_table :chapters_events do |t|
      t.integer :chapter_id, index: true
      t.integer :event_id, index: true
    end
  end
end
