class CreateChaptersMeetings < ActiveRecord::Migration
  def change
    create_table :chapters_meetings do |t|
      t.belongs_to :chapter, index: true
      t.belongs_to :meeting, index: true
    end
  end
end
