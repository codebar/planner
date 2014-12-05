class AddStudentAndCoachSpacesToEvent < ActiveRecord::Migration
  def change
    add_column :events, :coach_spaces, :integer
    add_column :events, :student_spaces, :integer
  end
end
