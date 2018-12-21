class Workshop < ActiveRecord::Migration
  def change
    add_column :workshops, :spreadsheet_id, :string
  end
end
