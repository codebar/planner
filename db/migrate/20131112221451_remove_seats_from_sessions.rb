class RemoveSeatsFromSessions < ActiveRecord::Migration[4.2]
  def change
    remove_column :sessions, :seats, :integer
  end
end
