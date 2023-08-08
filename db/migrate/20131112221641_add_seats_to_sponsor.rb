class AddSeatsToSponsor < ActiveRecord::Migration[4.2]
  def change
    add_column :sponsors, :seats, :integer, default: 15
  end
end
