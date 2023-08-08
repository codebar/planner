class AddSlugToChapter < ActiveRecord::Migration[4.2]
  def change
    add_column :chapters, :slug, :string
  end
end
