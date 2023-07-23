class AddUniqueIndexToEventSlug < ActiveRecord::Migration[4.2]
  def change
    add_index :events, :slug, unique: true
  end
end
