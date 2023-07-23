class AddTwitterHandleAndIdToChapter < ActiveRecord::Migration[4.2]
  def change
    add_column :chapters, :twitter, :string
    add_column :chapters, :twitter_id, :string
  end
end
