class AddChapterToCourse < ActiveRecord::Migration[4.2]
  def change
    add_reference :courses, :chapter, index: true
  end
end
