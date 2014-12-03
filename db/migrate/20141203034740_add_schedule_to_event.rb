class AddScheduleToEvent < ActiveRecord::Migration
  def change
    add_column :events, :schedule, :text
  end
end
