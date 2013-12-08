class CreateMeetings < ActiveRecord::Migration
  def change
    create_table :meetings do |t|
      t.datetime :date_and_time
      t.integer :duration, default: 120
      t.string :lanyrd_url
      t.integer :venue_id, index: true

      t.timestamps
    end
  end
end
