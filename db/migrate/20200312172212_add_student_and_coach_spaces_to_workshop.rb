class AddStudentAndCoachSpacesToWorkshop < ActiveRecord::Migration
  def change
    add_column :workshops, :student_spaces, :integer, default: 0
    add_column :workshops, :coach_spaces, :integer, default: 0
  end
end
