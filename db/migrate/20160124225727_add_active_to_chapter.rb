class AddActiveToChapter < ActiveRecord::Migration
  def change
    add_column :chapters, :active, :boolean, null: true, default: true
  end
end
