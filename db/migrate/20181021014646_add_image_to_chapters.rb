class AddImageToChapters < ActiveRecord::Migration
  def change
    add_column :chapters, :image, :string
  end
end
