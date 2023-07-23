class RemoveTimeFromWorkshops < ActiveRecord::Migration[4.2]
  def change
    remove_column :workshops, :time, :datetime
  end
end
