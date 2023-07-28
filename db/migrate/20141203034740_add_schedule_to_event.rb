class AddScheduleToEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :schedule, :text
  end
end
