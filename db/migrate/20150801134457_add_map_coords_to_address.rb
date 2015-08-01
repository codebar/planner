class AddMapCoordsToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :latitude, :string
    add_column :addresses, :longitude, :string
  end
end
