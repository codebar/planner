class AddTogglableFieldsToEvent < ActiveRecord::Migration
  def change
    add_column :events, :display_students, :boolean
    add_column :events, :display_coaches, :boolean
  end
end
