class AddCoachDescriptionToEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :coach_description, :text
  end
end
