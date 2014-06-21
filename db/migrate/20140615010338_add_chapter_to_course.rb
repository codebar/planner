class AddChapterToCourse < ActiveRecord::Migration
  def change
    add_reference :courses, :chapter, index: true
  end
end
