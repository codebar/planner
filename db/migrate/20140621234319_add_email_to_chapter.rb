class AddEmailToChapter < ActiveRecord::Migration[4.2]
  def change
    add_column :chapters, :email, :string
  end
end
