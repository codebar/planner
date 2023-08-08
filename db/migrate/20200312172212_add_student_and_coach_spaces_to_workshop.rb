class AddStudentAndCoachSpacesToWorkshop < ActiveRecord::Migration[4.2]
  def change
    add_column :workshops, :student_spaces, :integer, default: 0
    add_column :workshops, :coach_spaces, :integer, default: 0
  end
end
