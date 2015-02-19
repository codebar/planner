class AddSlugToChapter < ActiveRecord::Migration
  def change
    add_column :chapters, :slug, :string
  end
end
