class AddSeatsToSession < ActiveRecord::Migration[4.2]
  def change
    add_column :sessions, :seats, :integer, default: 15
  end
end
