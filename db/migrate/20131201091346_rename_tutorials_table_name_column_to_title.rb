class RenameTutorialsTableNameColumnToTitle < ActiveRecord::Migration[4.2]
  def change
  	 rename_column :tutorials, :name, :title
  end
end
