class CreateAnnouncements < ActiveRecord::Migration
  def change
    create_table :announcements do |t|
      t.datetime :expires_at
      t.text :message
      t.references :created_by, index: true

      t.timestamps
    end
  end
end
