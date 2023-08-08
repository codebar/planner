class AddActiveToChapter < ActiveRecord::Migration[4.2]
  def change
    add_column :chapters, :active, :boolean, null: true, default: true
  end
end
