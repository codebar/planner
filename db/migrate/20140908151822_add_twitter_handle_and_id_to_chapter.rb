class AddTwitterHandleAndIdToChapter < ActiveRecord::Migration
  def change
    add_column :chapters, :twitter, :string
    add_column :chapters, :twitter_id, :string
  end
end
