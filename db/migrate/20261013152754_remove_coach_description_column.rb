class RemoveCoachDescriptionColumn < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      remove_column :events, :coach_description, :text
    end
  end
end
