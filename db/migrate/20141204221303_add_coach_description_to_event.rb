class AddCoachDescriptionToEvent < ActiveRecord::Migration
  def change
    add_column :events, :coach_description, :text
  end
end
