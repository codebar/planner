class AddDescriptionToMeeting < ActiveRecord::Migration
  def change
    add_column :meetings, :description, :string
  end
end
