class AddNameToMeeting < ActiveRecord::Migration[4.2]
  def change
    add_column :meetings, :name, :string
  end
end
