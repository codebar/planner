class AddTimeToSessions < ActiveRecord::Migration
  def change
    add_column :sessions, :time, :datetime
  end
end
