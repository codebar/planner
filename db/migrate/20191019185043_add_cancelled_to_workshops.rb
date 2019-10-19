class AddCancelledToWorkshops < ActiveRecord::Migration
  def change
    add_column :workshops, :cancelled, :boolean, null: false, default: false
  end
end
