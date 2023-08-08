class AddImageToChapters < ActiveRecord::Migration[4.2]
  def change
    add_column :chapters, :image, :string
  end
end
