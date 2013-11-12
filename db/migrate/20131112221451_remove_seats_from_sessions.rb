class RemoveSeatsFromSessions < ActiveRecord::Migration
  def change
    remove_column :sessions, :seats, :integer
  end
end
