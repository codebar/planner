class AddCoachAndStudentQuestionnaireToEvent < ActiveRecord::Migration
  def change
    add_column :events, :coach_questionnaire, :string
    add_column :events, :student_questionnaire, :string
  end
end
