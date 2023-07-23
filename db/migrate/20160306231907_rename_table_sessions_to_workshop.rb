class RenameTableSessionsToWorkshop < ActiveRecord::Migration[4.2]
  def change
    rename_table :sessions, :workshops
  end
end
