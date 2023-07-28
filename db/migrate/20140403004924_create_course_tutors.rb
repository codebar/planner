class CreateCourseTutors < ActiveRecord::Migration[4.2]
  def change
    create_table :course_tutors do |t|
      t.belongs_to :course, index: true
      t.belongs_to :tutor, index: true

      t.timestamps
    end
  end
end
