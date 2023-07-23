class AddEndDtToMeetingsCourses < ActiveRecord::Migration[4.2]
  def change
    add_column :meetings, :ends_at, :datetime
    add_column :courses, :ends_at, :datetime
  end
end
