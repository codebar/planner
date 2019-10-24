class AddEndsAtToWorkshops < ActiveRecord::Migration
  def change
    add_column :workshops, :ends_at, :datetime
  end
end
