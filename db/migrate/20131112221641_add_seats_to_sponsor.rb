class AddSeatsToSponsor < ActiveRecord::Migration
  def change
    add_column :sponsors, :seats, :integer, default: 15
  end
end
