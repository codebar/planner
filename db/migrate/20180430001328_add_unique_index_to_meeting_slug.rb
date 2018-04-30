class AddUniqueIndexToMeetingSlug < ActiveRecord::Migration
  def change
    add_index :meetings, :slug, unique: true
  end
end
