class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
      t.string :reminder_type
      t.string :reminder_id
      t.datetime :date_and_time
      t.integer :count

      t.timestamps
    end
  end
end
