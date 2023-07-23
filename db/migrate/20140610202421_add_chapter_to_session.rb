class AddChapterToSession < ActiveRecord::Migration[4.2]
  def change
    add_reference :sessions, :chapter, index: true
  end
end
