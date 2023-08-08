class AddUniqueIndexToMeetingSlug < ActiveRecord::Migration[4.2]
  def change
    add_index :meetings, :slug, unique: true
  end
end
