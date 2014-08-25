class DropReminders < ActiveRecord::Migration
  def change
    drop_table :reminders
  end
end
