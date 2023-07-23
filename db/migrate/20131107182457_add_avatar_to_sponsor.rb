class AddAvatarToSponsor < ActiveRecord::Migration[4.2]
  def change
    add_column :sponsors, :avatar, :string
  end
end
