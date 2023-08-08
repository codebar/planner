class AddTogglableFieldsToEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :display_students, :boolean
    add_column :events, :display_coaches, :boolean
  end
end
