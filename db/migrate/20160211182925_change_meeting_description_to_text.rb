class ChangeMeetingDescriptionToText < ActiveRecord::Migration
  def change
    change_column :meetings, :description, :text
  end
end
