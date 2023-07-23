class CreateGroupAnnouncements < ActiveRecord::Migration[4.2]
  def change
    create_table :group_announcements do |t|
      t.references :announcement, index: true
      t.references :group, index: true

      t.timestamps
    end
  end
end
