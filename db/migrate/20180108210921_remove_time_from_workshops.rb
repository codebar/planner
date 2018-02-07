class RemoveTimeFromWorkshops < ActiveRecord::Migration
  def change
    remove_column :workshops, :time, :datetime
  end
end
