class CreateAttendanceWarnings < ActiveRecord::Migration[4.2]
  def change
    create_table :attendance_warnings do |t|
      t.references :member, index: true
      t.references :sent_by, index: true

      t.timestamps
    end
  end
end
