class AddEndDtToMeetingsCourses < ActiveRecord::Migration
  def change
    add_column :meetings, :ends_at, :datetime
    add_column :courses, :ends_at, :datetime
  end
end
