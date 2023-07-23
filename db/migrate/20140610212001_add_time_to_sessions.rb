class AddTimeToSessions < ActiveRecord::Migration[4.2]
  def change
    add_column :sessions, :time, :datetime
  end
end
