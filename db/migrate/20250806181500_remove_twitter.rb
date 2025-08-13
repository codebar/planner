class RemoveTwitter < ActiveRecord::Migration[7.0]
  def change
    remove_column :chapters, :twitter
    remove_column :chapters, :twitter_id
    remove_column :members, :twitter
  end
end
