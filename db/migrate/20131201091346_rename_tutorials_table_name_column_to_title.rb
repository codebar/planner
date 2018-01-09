class RenameTutorialsTableNameColumnToTitle < ActiveRecord::Migration
  def change
  	 rename_column :tutorials, :name, :title
  end
end
