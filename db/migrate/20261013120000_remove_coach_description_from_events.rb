class RemoveCoachDescriptionFromEvents < ActiveRecord::Migration[8.1]
  def change
    safety_assured { remove_column :events, :coach_description, :text }
  end
end
