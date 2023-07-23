class AddEndsAtToWorkshops < ActiveRecord::Migration[4.2]
  def change
    add_column :workshops, :ends_at, :datetime
  end
end
