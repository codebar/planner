class CreateAnnouncements < ActiveRecord::Migration[4.2]
  def change
    create_table :announcements do |t|
      t.datetime :expires_at
      t.text :message
      t.references :created_by, index: true

      t.timestamps
    end
  end
end
