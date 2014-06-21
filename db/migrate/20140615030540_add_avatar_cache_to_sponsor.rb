class AddAvatarCacheToSponsor < ActiveRecord::Migration
  def change
    add_column :sponsors, :image_cache, :string
  end
end
