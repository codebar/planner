class AddDescriptionToMeeting < ActiveRecord::Migration[4.2]
  def change
    add_column :meetings, :description, :string
  end
end
