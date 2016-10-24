class RenameTableSessionsToWorkshop < ActiveRecord::Migration
  def change
    rename_table :sessions, :workshops
  end
end
