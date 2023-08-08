class DropReminders < ActiveRecord::Migration[4.2]
  def change
    drop_table :reminders
  end
end
