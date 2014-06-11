class AddChapterToSession < ActiveRecord::Migration
  def change
    add_reference :sessions, :chapter, index: true
  end
end
