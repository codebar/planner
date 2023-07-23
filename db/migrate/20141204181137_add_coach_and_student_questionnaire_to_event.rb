class AddCoachAndStudentQuestionnaireToEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :coach_questionnaire, :string
    add_column :events, :student_questionnaire, :string
  end
end
