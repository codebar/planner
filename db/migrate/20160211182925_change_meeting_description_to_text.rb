class ChangeMeetingDescriptionToText < ActiveRecord::Migration[4.2]
  def change
    change_column :meetings, :description, :text
  end
end
