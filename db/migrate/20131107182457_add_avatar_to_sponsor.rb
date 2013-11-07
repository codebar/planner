class AddAvatarToSponsor < ActiveRecord::Migration
  def change
    add_column :sponsors, :avatar, :string
  end
end
