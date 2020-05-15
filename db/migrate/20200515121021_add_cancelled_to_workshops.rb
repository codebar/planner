class AddCancelledToWorkshops < ActiveRecord::Migration
  def change
    add_column :workshops, :cancelled, :boolean, default: false
  end
end
