class AddAvatarCacheToSponsor < ActiveRecord::Migration[4.2]
  def change
    add_column :sponsors, :image_cache, :string
  end
end
