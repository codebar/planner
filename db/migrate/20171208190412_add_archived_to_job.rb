class AddArchivedToJob < ActiveRecord::Migration
  def change
  	add_column :jobs, :archived, :boolean, default: false 
  	add_column :jobs, :archived_by_id, :integer, index: true
  end
end
