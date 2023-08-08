class AddMapCoordsToAddress < ActiveRecord::Migration[4.2]
  def change
    add_column :addresses, :latitude, :string
    add_column :addresses, :longitude, :string
  end
end
