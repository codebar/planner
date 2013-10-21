class AddSeatsToSession < ActiveRecord::Migration
  def change
    add_column :sessions, :seats, :integer, default: 15
  end
end
